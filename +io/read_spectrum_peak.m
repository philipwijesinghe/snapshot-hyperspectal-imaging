function [spec_max, spec] = read_spectrum_peak(file_spec)

import io.sifreadnk

spec = sifreadnk(file_spec);
[~, ind] = max(spec.imageData);
spec_max = spec.axisWavelength(ind);

end

