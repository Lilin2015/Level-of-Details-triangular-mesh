function [rV,rF] = uniformV(V,F)
    [Vs,index]=sortrows(V);
    [~,ia,~]=unique(Vs,'rows');
    bool_save = zeros(size(V,1),1);
    bool_save(ia)=1;
    index = [index,bool_save];
    %%
    fprintf('\n模型优化中...\n');
    Vnum = size(index,1);
    count = 0;
    for i = 1 : Vnum
        if index(i,2)== 1
            ref_v = index(i,1);
        else
            del_v = index(i,1);
            V(del_v,:) = NaN;
            F(F == del_v) = ref_v;
        end 
        fprintf(1, repmat('\b',1,count));
        count = fprintf('%0.2f%%',100*i/Vnum);
    end
    fprintf('\n');
    f_remove = sum(diff(sort(F,2),[],2) == 0, 2) > 0;
    F(f_remove,:) = [];
    [rV,rF] = rectifyindex( V,F );
end

