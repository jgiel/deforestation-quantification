function I = setZero(I, idxs)
    %SETZERO sets pixels in I at specified indexes (idx) to 0
    Zeros = zeros(size(I));
    I(idxs) = Zeros(idxs);
end
