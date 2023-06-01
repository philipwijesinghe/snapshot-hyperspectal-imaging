function result = ismymatrix(obj)
import third_party.yaml.*;
result = ndims(obj) == 2 && all(size(obj) > 1);
end
