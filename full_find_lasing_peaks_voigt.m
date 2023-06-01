%% Function to find peak positions from a series of spectra
% The function takes in a spectral timeseries in ascii format and then
% finds/fits the peaks in each one.

% Output:
% L = List of peak positions to be used for refractive index sensing
% int = List of peak intensity
% err = List of error intervals

% Adapted from code developed by Isla Barnard (Ref [37] in report)
% Lewis Woolfson - Apr 2017 - lw58@st-andrews.ac.uk
%adapted to do a voigt fit -scc23 14/04/2020


% TODO: Output to a file
% fill in null values

function [L,int,err, width,err2]=find_lasing_peaks_voigt(max_no_peaks, min_peak_prominence, lower_lambda, upper_lambda,wavelength, data)

% mainpath = './';
% filename = 'lasing_OD17-10'
%
% [wavelength,data] =sifconvert([filename,'.sif'])


%timeseries = dlmread(f, '', [0 2000 1599 3000]);
timeseries = [wavelength.',data];
%timeseries(:,50:end) = [];

% % Remove wavelengths outside region of interest
condition = (timeseries(:,1)>lower_lambda)&(timeseries(:,1)<upper_lambda);
timeseries(~condition,:) = [];
%
% Error confidence interval (default 95%)
confidence = 0.95;

lambda=timeseries(:,1); % take only column 1 for the wavelengths
SPECTRA=timeseries(:,2:end); % take all other columns for the spectra data
n_data=(size(timeseries,2)-1); %number of data sets

% SPECTRA=detrend(SPECTRA); %detrend each spectra set (Caution: this makes
%the fit result dependent on the wavelength range specified with lower and
%upper lambda, problematic with very intense peaks)
%% Gaussian fit to each lasing peak

LASING_SPECTRA=zeros(n_data,max_no_peaks); % peak positions output
LASING_INTENSITY=zeros(n_data,max_no_peaks); % peak intensity output
LASING_ERROR=zeros(n_data,max_no_peaks); % confidence intervals output

m=0;
k=0;
l=0;
for j=1:n_data %for each dataset... (j-th dataset)
    n_data;
    spectrum=SPECTRA(:,j);
    
    % calculate the minimum lasing threshold as 5 standard deviations from
    
    min_lasing_threshold = 5;
    
    m=m+1;
    %if no lasing, go to next spectra
    if (max(spectrum) < min_lasing_threshold)
        disp('no lasing detected in data set number:')
        disp(j)
        continue
    end
    
    
        
    clear pks locs
    
    % locate peaks in spectrum (may add 'MinPeakDistance',1.0,
    [pks,locs,w]=findpeaks(spectrum, lambda,'MinPeakDistance',1.0,...
        'MinPeakProminence', min_peak_prominence);
    
    n=size(pks,1);
%      if n ~= max_no_peaks
%         disp found more peaks
%     end
    %if fitting more than one peak
    if(n > 1)
        % create a window around each peak
        d=diff(locs);
        a=zeros((size(d,1) + 2),1);
        a(1)=d(1);
        a(2:(size(d,1))+1)=d(:);
        a(end)=d(end);
        a=a./6;                     %might need to be adjusted (not suitable for double peaks)
    end
    %     subtract background
    
    
    % fit Gaussian across each window
    for i=1:n
        k=k+1;
        %if fitting more than one peak
        %          clear X Y lower_limit upper_limit mask C Ci p0
        if(n > 1)
            lower_limit(i)=locs(i)-a(i);
            upper_limit(i)=locs(i)+a(i+1);
            mask=(lambda>lower_limit(i))&(lambda<upper_limit(i));
            
            X=lambda(mask);
            Y=spectrum(mask);
        else
            %if just fitting the one peak
            X = lambda;
            Y = spectrum;
            lower_limit(i) = lower_lambda;
            upper_limit(i) = upper_lambda;
        end
        %         Y = Y - mean(Y(1:10))
        %         for u = 1:length(Y)
        %            if Y(u) <0
        %                Y(u) = 0;
        %            end
        %
        %         end
%         initial guesses
        p0 = [ pks(i),locs(i),w(i)./2.355,0.5];
        %             alpha = 30000;
        %             fun = @(p)fun_;(p, X, Y, alpha);
        %             bestp = fminsearch(fun, p0);
        %             yfit = sumvoigt2(bestp, X);
        %yfit = sumvoigt2(p0, X);
        
        %             weight = fun_voigt(bestp, X, Y, 0);
        %
        %             figure;
        %             plot(X,Y,'k',X,yfit,'r')
        %             bestp
        
        %[ lb , ub , parvec0 ] = BoundGen( p0,X,Y,1,'bg0',p0,1);
        opts = optimset('Display','off','MaxIter',50000);
        
        lb = [ pks(i)*0.95, lower_limit(i), w(i)./2.355/5, 0];
        ub = [ pks(i)*1.05, upper_limit(i), w(i)./2.355*5 ,1];
        [parameters,resnorm,residual,exitflag,output,lambda2,jacobian]=lsqcurvefit(@sumvoigt1,p0,X,Y,lb,ub,opts);
% %         
%         Xn = linspace(min(X(:)),max(X(:)),1000);
%                 yfit2 = sumvoigt1(parameters, Xn);
%                 figure;
%                 plot(X,Y,'k',Xn,yfit2,'r')
%                 parameters
%         
        C = parameters;
        Ci = nlparci(parameters,residual,'jacobian',jacobian)';
        %             minConf = abs(parameters - conf(2,:));
        %             maxConf = abs(parameters - conf(1,:));
        %             conf = mean([minConf;maxConf]);
        %             conf
        
        
        %             fo = fitoptions('gauss1', 'Lower', [0, lower_limit, 0], ...
        %                 'Upper', [Inf, upper_limit, Inf]);
        %              [f,gof]=fit(X,Y,'gauss1',fo); %perform 1-term gaussian fit
        %              C = coeffvalues(f);  % extract coefficients
        %              Ci = confint(f,confidence); %extract confidence intervals
        %
        %              % redundant code, fit options won't allow it.
        %              if (C(2) < lower_limit || C(2) > upper_limit)
        %                  % if it returns a centroid value outside the window
        %                  warning('Gauss1 returned a negative fit centroid position for peak number %d at spectra number %d. Attempting gauss2 fit...', i,m);
        %              end
        
        
        
        
        % if the fit result is greater than maximum wavelength (redundant)
        
        % add fit results from this spectrum to output variables
        
        
%%         calculate the FWHM 
% Xn = linspace(min(X(:)),max(X(:)),1000);
% yfit2 = sumvoigt1(parameters, Xn);
% figure;
% plot(X,Y,'k',Xn,yfit2,'r');
% test = yfit2/max(yfit2); %normalised
% fwhm= 0.5;
% N = length(test);
% s = 2;
%   [garbage,centerindex]=max(test);
% while sign(test(s)-fwhm) == sign(test(s-1)-fwhm)
%     s = s+1;
% end                                   %first crossing is between v(i-1) & v(i)
% interp = (fwhm-test(s-1)) / (yfit2(s)-test(s-1));
% tlead = Xn(s-1) + interp*(Xn(s)-Xn(s-1));
% s = centerindex+1;                    %start search for next crossing at center
% while ((sign(test(s)-fwhm) == sign(test(s-1)-fwhm)) & (s <= N-1))
%     s = s+1;
% end
% 
%     Ptype = 1;
% 
%     interp = (fwhm-test(s-1)) / (test(s)-test(s-1));
%     ttrail = Xn(s-1) + interp*(Xn(s)-Xn(s-1));
%     width = ttrail - tlead;


        LASING_INTENSITY(m,i)=C(1);
        LASING_SPECTRA(m,i)=C(2);
        LASING_WIDTH(m,i)=C(3);
        %        LASING_RSQR(m,i)=gof.rsquare;
        
        LASING_ERROR(m,i)=(Ci(2,2)-Ci(1,2))/2;
        LASING_WIDTHERROR (m,i) = (Ci(2,3)-Ci(1,3))/2;
        LASING_RSQR(m,i)=resnorm;
    end
end


clear mask
err = LASING_ERROR;
err2= LASING_WIDTHERROR;
int = LASING_INTENSITY;
width =LASING_WIDTH;
L=LASING_SPECTRA;

[int, s] = sort(int, 'descend');
err = err(s);
err2 = err2(s);
width = width(s);
L = L(s);



% save([filename,'.txt'],'L','-ascii');
% save([filename,'error.txt'],'err','-ascii');
end