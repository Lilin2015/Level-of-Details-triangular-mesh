function [ simV,simF ] = simplification( V,F,percent )

%% 预处理

    % 顶点数nv，预计保留的顶点数pv，面数nf
    nv = size(V,1);
    pv = percent*nv;
    nf = size(F,1);
    % 计算平面法向量，N为【面数，3】的矩阵
    N = face_normal(V,F)';
    % 计算平面方程参数，p为【面数，4】的矩阵，4列分别为平面方程的4个参数
    p = [N, -sum(N .* V(F(:,1),:), 2)];
    % 面的基本误差矩阵，Qf是【4，4，面数】的矩阵
    Qf = bsxfun(@times, permute(p, [2,3,1]), permute(p, [3,2,1]));
    % 点的基本误差矩阵，Qv(:,:,n)是所有与第n个顶点相连的面的基本误差矩阵之和
    Qv = zeros(4,4,nv);
    valence = zeros(nv,1);
    for i = 1:nf
        for j = 1:3
            valence(F(i,j)) = valence(F(i,j)) + 1;
            Qv(:,:,F(i,j)) = Qv(:,:,F(i,j)) + Qf(:,:,i);
        end
    end
    % 提取模型中的边缘，E是【边缘数，2】的矩阵
    TR = triangulation(F,V); E = edges(TR); ne = size(E,1);
    % 边缘的基本误差矩阵，Qe(:,:,n)是所有与第n个边缘相连的顶点的基本误差矩阵之和
    Qe = Qv(:,:,E(:,1)) + Qv(:,:,E(:,2));
    
%% 删除一条边缘意味着将边缘的两个顶点合并为一个，合并后的定位位置有三个候选，分别为：两个顶点及中点, 此处计算删除各边缘并以三个候选为替代顶点对模型误差的影响，即各个边缘的3中删除代价

    % 各候选顶点的坐标
    v1 = permute([V(E(:,1),:),ones(ne,1)], [2,3,1]);
    v2 = permute([V(E(:,2),:),ones(ne,1)], [2,3,1]);
    vm = 0.5 .* (v1 + v2);    v = [v1, v2, vm];
    % 计算消除各边的误差代价，cost是【边缘数，3】的矩阵，每行对应一条边缘，3列分别对应以三种候选顶点替代原有边的代价
    cost = zeros(ne,3); 
%     cost(:,1) = sum(squeeze(sum(bsxfun(@times,v1,Qe),1)).*squeeze(v1),1)';
%     cost(:,2) = sum(squeeze(sum(bsxfun(@times,v2,Qe),1)).*squeeze(v2),1)';
%     cost(:,3) = sum(squeeze(sum(bsxfun(@times,vm,Qe),1)).*squeeze(vm),1)';
    cost(:,1) = sum(squeeze(sum(bsxfun(@times,v1,Qe),1)).*squeeze(v1),1)';
    cost(:,2) = sum(squeeze(sum(bsxfun(@times,v2,Qe),1)).*squeeze(v2),1)';
    cost(:,3) = sum(squeeze(sum(bsxfun(@times,vm,Qe),1)).*squeeze(vm),1)';
%% 删除边缘，每次删除代价最小的边缘，并更新所有受影响的参数

    dv = nv-pv;
    count = 0;
    fprintf('\n');
    for i = 1:nv-pv
        % 找到消除代价最小的边缘e，及其顶点的替代方式
        [min_cost, vidx] = min(cost,[],2);
        [~, k] = min(min_cost);
        e = E(k,:);
        % 从顶点表V中删除被删除边缘的任意一个顶点，根据替代方式更新另一个顶点
        V(e(1),:) = v(1:3, vidx(k), k)';
        V(e(2),:) = NaN;
        % 从顶点基本误差矩阵Qv中删除被删除边缘的任意一个顶点的基本误差矩阵，根据替代方式更新另一个顶点的基本误差矩阵
        Qv(:,:,e(1)) = Qv(:,:,e(1)) + Qv(:,:,e(2));
        Qv(:,:,e(2)) = NaN;
        % 替换面片表F中被删除顶点的索引，删除因删除边缘变为线段的面
        F(F == e(2)) = e(1);
        f_remove = sum(diff(sort(F,2),[],2) == 0, 2) > 0;
        F(f_remove,:) = [];
        % 替换边缘表E中被删除顶点的索引，移除被删除的边缘，移除被重叠的边缘
        E(E == e(2)) = e(1);    E(k,:) = [];    [E,ia,~] = unique(sort(E,2), 'rows');
        % 移除消失的或冗余的边缘删除代价表、边缘基本误差矩阵、顶点
        cost(k,:) = [];    Qe(:,:,k) = [];    v(:,:,k) = [];
        cost = cost(ia,:); Qe = Qe(:,:,ia);   v = v(:,:,ia);
        % 找到所有与新顶点相连的边缘，更新其基本误差矩阵
        pair = sum(E == e(1), 2) > 0;
        npair = sum(pair);
        Qe(:,:,pair) = Qv(:,:,E(pair,1)) + Qv(:,:,E(pair,2));
        % 找到所有与新顶点相连的边缘，更新其删除代价矩阵
        pair_v1 = permute([V(E(pair,1),:),ones(npair,1)], [2,3,1]);
        pair_v2 = permute([V(E(pair,2),:),ones(npair,1)], [2,3,1]);
        pair_vm = 0.5 .* (pair_v1 + pair_v2);
        v(:,:,pair) = [pair_v1, pair_v2, pair_vm];
%         cost(pair,1) = sum(squeeze(sum(bsxfun(@times,pair_v1,Qe(:,:,pair)),1)).*squeeze(pair_v1),1)';
%         cost(pair,2) = sum(squeeze(sum(bsxfun(@times,pair_v2,Qe(:,:,pair)),1)).*squeeze(pair_v2),1)';
%         cost(pair,3) = sum(squeeze(sum(bsxfun(@times,pair_vm,Qe(:,:,pair)),1)).*squeeze(pair_vm),1)';
        cost(pair,1) = sum(reshape(sum(bsxfun(@times,pair_v1,Qe(:,:,pair)),1),[4,npair]).*squeeze(pair_v1),1)';
        cost(pair,2) = sum(reshape(sum(bsxfun(@times,pair_v2,Qe(:,:,pair)),1),[4,npair]).*squeeze(pair_v2),1)';
        cost(pair,3) = sum(reshape(sum(bsxfun(@times,pair_vm,Qe(:,:,pair)),1),[4,npair]).*squeeze(pair_vm),1)';
        % 显示进度
        fprintf(1, repmat('\b',1,count));
        count = fprintf('%0.4f%%',100*i/dv);
    end
    fprintf('\n');
    [ simV,simF ] = rectifyindex( V,F );
end