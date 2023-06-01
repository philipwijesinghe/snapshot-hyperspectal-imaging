function result = isord(obj)
import third_party.yaml.*;
result = ~iscell(obj) && any(size(obj) > 1);
end
