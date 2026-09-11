function [ mcore ] = Build_mcore( NN, nXB, km, kms, nBS, ka, kas )
% Build the basic 'mcore' matrix of spring constants, before there is any
% cross-bridge binding.
%
% Inputs:
% NN--total number of XB and BS
% nXB--number of myosin XB
% km--myosin stiffnes between sites (myosin backbone)
% kms--thick filament backbone stiffness towards m-line (i.e. series myosin
% stiffness outlining the M-zone or bare zone)
% nBS--number of actin binding sites
% k--thin filametn stiffness between sites (actin backbone stiffness)
% kas--series thin-filament stiffness towards Z-line

%  building the matrix of spring constants (NN = nXB+nBS)
for ii = 1:NN,
    for jj = 1:NN,
        mcore(ii,jj) = 0.0;   % Initialize NN by NN to zero
    end
end
%diagonal for thick filaments
for ii=1:nXB mcore(ii,ii) = -2.0*km; end
mcore(1,1) = -km-kms;  % Frist and last diagnonals a little different
mcore(nXB,nXB) = -km;
% off diagonals for the thick filaments
for ii = 1:nXB-1
    mcore(ii,ii+1) = km;
    mcore(ii+1,ii) = km;
end

%diagonal for the thin filaments
for ii = nXB+1:nXB+nBS mcore(ii,ii) = -2.0*ka; end
mcore(nXB+1,nXB+1) = -ka;
mcore(nXB+nBS,nXB+nBS) = -ka - kas;
%off diagaonals for the thin filaments
for ii = nXB+1:nXB+nBS-1
    mcore(ii,ii+1) = ka;
    mcore(ii+1,ii) = ka;
end


end

