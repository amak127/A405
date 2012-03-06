 clear all;
 %plot a sounding from soundings.nc
 filename='springfield.nc';
 file_struct=nc_info(filename);
 c=constants;
 %
 % graph the first sounding pressure and temperature
 %
 sound_var = file_struct.Dataset(3).Name;
 press=nc_varget(filename,sound_var,[0,0],[Inf,1]);
 temp=nc_varget(filename,sound_var,[0,2],[Inf,1]);
 dewpoint=nc_varget(filename,sound_var,[0,3],[Inf,1]);
 fh=figure(1);
 semilogy(temp,press)
 hold on;
 semilogy(dewpoint,press)
 set(gca,'yscale','log','ydir','reverse');
 ylim([400,1000]);
 ylabel('press (hPa)')
 xlabel('Temp (deg C)')
 title('sounding 1')
 hold off;
 figHandle=figure(2);
 skew=30.;
 [figHandle,outputws,handlews]=makeSkew(figHandle,skew);
 xtemp=convertTempToSkew(temp,press,skew);
 xdew=convertTempToSkew(dewpoint,press,skew);
 semilogy(xtemp,press,'g-','linewidth',5);
 semilogy(xdew,press,'b-','linewidth',5);
 [xTemp,thePress]=ginput(1);    %clicking on graph saves these plots
 Tclick=convertSkewToTemp(xTemp,thePress,skew);
 thetaeVal=thetaes(Tclick + c.Tc,thePress*100.);
 fprintf('ready to draw moist adiabat, thetae=%8.2f\n',thetaeVal);
 ylim([400,1000.])
 hold on;

% $$$ double Mar-17-2011-00Z(dim_138, var_cols) ;
% $$$ double Mar-17-2011-12Z(dim_139, var_cols) ;
% $$$ double Mar-18-2011-00Z(dim_128, var_cols) ;
% $$$ double Mar-18-2011-12Z(dim_142, var_cols) ;
% $$$ double Mar-19-2011-00Z(dim_39, var_cols) ;

%===============================================================
%Draw moist adiabat from point near surface found by ginput using
%sounding read from springfield.nc
moistPress = 400e2:1000:thePress*100;
for i = 1:numel(moistPress)
    moistAdiabat(i) = findTmoist(thetaeVal,moistPress(i));   %K, Pa
    xmoist(i) = convertTempToSkew(moistAdiabat(i)-c.Tc,moistPress(i)./100,skew); %degC, hPa
end
%Plotting a red line for the moist adiabat
plot(xmoist,moistPress*0.01,'r-','linewidth',5);
hold off;

%Calculating CAPE for sounding between 750-400 hPa using adiabat
%from ginput and Wallace&Hobbs Equation (8.4) on page 345.
%   CAPE = R_d*integral[Tv' - Tv]dlnP <from EL to LFC>
%or if we ignore the small virtual temperature correction, the
%integral is simply the area on the skew-T lnP plot from the
%LFC (Level of Free Convection) and EL (Equilibrium Level), bounded
%by the environmental sounding on the left and a moist adiabat on
%the right.

capePress = 400e2:500:750e2;



%Sorry Phil, I understood the logic behind just finding the total amount of
%area and adding together the positive and negative values to get the net
%work, but I couldn't transfer or convert that over into Matlab code.