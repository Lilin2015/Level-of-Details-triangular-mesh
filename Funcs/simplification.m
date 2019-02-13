function [ simV,simF ] = simplification( V,F,percent )

%% Ԥ����

    % ������nv��Ԥ�Ʊ����Ķ�����pv������nf
    nv = size(V,1);
    pv = percent*nv;
    nf = size(F,1);
    % ����ƽ�淨������NΪ��������3���ľ���
    N = face_normal(V,F)';
    % ����ƽ�淽�̲�����pΪ��������4���ľ���4�зֱ�Ϊƽ�淽�̵�4������
    p = [N, -sum(N .* V(F(:,1),:), 2)];
    % ��Ļ���������Qf�ǡ�4��4���������ľ���
    Qf = bsxfun(@times, permute(p, [2,3,1]), permute(p, [3,2,1]));
    % ��Ļ���������Qv(:,:,n)���������n��������������Ļ���������֮��
    Qv = zeros(4,4,nv);
    valence = zeros(nv,1);
    for i = 1:nf
        for j = 1:3
            valence(F(i,j)) = valence(F(i,j)) + 1;
            Qv(:,:,F(i,j)) = Qv(:,:,F(i,j)) + Qf(:,:,i);
        end
    end
    % ��ȡģ���еı�Ե��E�ǡ���Ե����2���ľ���
    TR = triangulation(F,V); E = edges(TR); ne = size(E,1);
    % ��Ե�Ļ���������Qe(:,:,n)���������n����Ե�����Ķ���Ļ���������֮��
    Qe = Qv(:,:,E(:,1)) + Qv(:,:,E(:,2));
    
%% ɾ��һ����Ե��ζ�Ž���Ե����������ϲ�Ϊһ�����ϲ���Ķ�λλ����������ѡ���ֱ�Ϊ���������㼰�е�, �˴�����ɾ������Ե����������ѡΪ��������ģ������Ӱ�죬��������Ե��3��ɾ������

    % ����ѡ���������
    v1 = permute([V(E(:,1),:),ones(ne,1)], [2,3,1]);
    v2 = permute([V(E(:,2),:),ones(ne,1)], [2,3,1]);
    vm = 0.5 .* (v1 + v2);    v = [v1, v2, vm];
    % �����������ߵ������ۣ�cost�ǡ���Ե����3���ľ���ÿ�ж�Ӧһ����Ե��3�зֱ��Ӧ�����ֺ�ѡ�������ԭ�бߵĴ���
    cost = zeros(ne,3); 
%     cost(:,1) = sum(squeeze(sum(bsxfun(@times,v1,Qe),1)).*squeeze(v1),1)';
%     cost(:,2) = sum(squeeze(sum(bsxfun(@times,v2,Qe),1)).*squeeze(v2),1)';
%     cost(:,3) = sum(squeeze(sum(bsxfun(@times,vm,Qe),1)).*squeeze(vm),1)';
    cost(:,1) = sum(squeeze(sum(bsxfun(@times,v1,Qe),1)).*squeeze(v1),1)';
    cost(:,2) = sum(squeeze(sum(bsxfun(@times,v2,Qe),1)).*squeeze(v2),1)';
    cost(:,3) = sum(squeeze(sum(bsxfun(@times,vm,Qe),1)).*squeeze(vm),1)';
%% ɾ����Ե��ÿ��ɾ��������С�ı�Ե��������������Ӱ��Ĳ���

    dv = nv-pv;
    count = 0;
    fprintf('\n');
    for i = 1:nv-pv
        % �ҵ�����������С�ı�Եe�����䶥��������ʽ
        [min_cost, vidx] = min(cost,[],2);
        [~, k] = min(min_cost);
        e = E(k,:);
        % �Ӷ����V��ɾ����ɾ����Ե������һ�����㣬���������ʽ������һ������
        V(e(1),:) = v(1:3, vidx(k), k)';
        V(e(2),:) = NaN;
        % �Ӷ������������Qv��ɾ����ɾ����Ե������һ������Ļ��������󣬸��������ʽ������һ������Ļ���������
        Qv(:,:,e(1)) = Qv(:,:,e(1)) + Qv(:,:,e(2));
        Qv(:,:,e(2)) = NaN;
        % �滻��Ƭ��F�б�ɾ�������������ɾ����ɾ����Ե��Ϊ�߶ε���
        F(F == e(2)) = e(1);
        f_remove = sum(diff(sort(F,2),[],2) == 0, 2) > 0;
        F(f_remove,:) = [];
        % �滻��Ե��E�б�ɾ��������������Ƴ���ɾ���ı�Ե���Ƴ����ص��ı�Ե
        E(E == e(2)) = e(1);    E(k,:) = [];    [E,ia,~] = unique(sort(E,2), 'rows');
        % �Ƴ���ʧ�Ļ�����ı�Եɾ�����۱���Ե���������󡢶���
        cost(k,:) = [];    Qe(:,:,k) = [];    v(:,:,k) = [];
        cost = cost(ia,:); Qe = Qe(:,:,ia);   v = v(:,:,ia);
        % �ҵ��������¶��������ı�Ե�����������������
        pair = sum(E == e(1), 2) > 0;
        npair = sum(pair);
        Qe(:,:,pair) = Qv(:,:,E(pair,1)) + Qv(:,:,E(pair,2));
        % �ҵ��������¶��������ı�Ե��������ɾ�����۾���
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
        % ��ʾ����
        fprintf(1, repmat('\b',1,count));
        count = fprintf('%0.4f%%',100*i/dv);
    end
    fprintf('\n');
    [ simV,simF ] = rectifyindex( V,F );
end