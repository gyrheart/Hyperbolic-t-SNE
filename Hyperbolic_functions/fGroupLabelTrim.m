function [GroupLabelTrim, label_index] = fGroupLabelTrim(GroupLabel)

GroupLabelTrim = [];
count = 0;
label_index = [];
for k = 1:size(GroupLabel,1)
    temp_str = GroupLabel(k,:);
    temp_str = strtrim(temp_str);

    if length(temp_str)>1
        count = count + 1;
        label_index = [label_index, k];
        GroupLabelTrim{count} = temp_str;
    end
end