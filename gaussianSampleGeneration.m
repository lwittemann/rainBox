%% Generating Error Function and Inverse Error Function using Approximations
%generate random variables
uni = rand(60000,1);
gauss = randn(120000,1);
%generate x values
x = 0:0.01:2;
%use approximation to generate erf(x) values
a = [0.278393, 0.230389, 0.000972, 0.078108];
erfx = 1 - (1./((1 + a(1)*x + a(2)*(x.^2) + a(3)*(x.^3) + a(4)*(x.^4)).^4));
erfx = [-flip(erfx(2:end)) erfx];
%use approximation to generate erfInverse(x) values
x = 0:0.01:1;
fastCalc = 1 - x.^2;
a = 0.140012;
inner = 2/(pi*a) + log(fastCalc)/2 ;
erfInvx = sqrt( sqrt(inner.^2 - log(fastCalc)/a ) - inner );
erfInvx = sqrt(2)*[-flip(erfInvx(2:end)), erfInvx];
%plot
subplot(2,1,1)
plot(-2:0.01:2,erfx,LineWidth=2)
title("\fontsize{20} Error function using Abramowitz and Stegun's Simplest Approximation")
xlabel('\fontsize{15} x')
xlim([-2 2])
subplot(2,1,2)
plot(-1:0.01:1,erfInvx,LineWidth=2)
title("\fontsize{20} Inverse Error Function using Sergei Winitzki's Global Pade Approximations")
xlabel('\fontsize{15} x')
xlim([-1 1])


%% Generating Normal Samples using Uniform Samples and Inverse Error Function Approximation
%generate x values for erfInv(x) using uniform random variables
x = 2*uni - 1;
%generate values for erfInv(x) 
fastCalc = 1 - x.^2;
a = 0.140012;
inner = 2/(pi*a) + log(fastCalc)/2 ;
erfInvx = sqrt( sqrt(inner.^2 - log(fastCalc)/a ) - inner );
erfInvx = sqrt(2)*[-flip(erfInvx(2:end)); erfInvx];
%plot
subplot(2,1,1)
histogram(gauss)
title("\fontsize{20} Histogram of MATLAB generated Normal R.V.'s")
xlim([-5 5])
subplot(2,1,2)
histogram(erfInvx)
title("\fontsize{20} Histogram of Normal R.V.'s Generated Using U[0,1] and Inverse Error Function Approximation")
xlim([-5 5])
%plot(-1:0.001:1,erfInvx)


%% Generating Normal Samples using Uniform Samples and Inverse Error Function Look-Up Table
%generate normal R.V.'s
gauss = randn(60000,1);
%generate x values for erfInv(x) and look up table of erfInv(x) values
x = linspace(0,1,1000);
lookUp = sqrt(2)*erfinv(x);
%generate uniform R.V.'s and array to store normal generated values in
unif = rand(60000,1) ;
gaussian = zeros(60000,1);
%loop through all uniform R.V.'s
for i = 1:60000
    %Since LUT ranges from 0->1, we can only apply U[1/2,1]. The uniform
    %R.V. is then converted to an index in the LUT for the normal R.V.
    %samples
    if unif(i,1) >= 1/2
        index = round((2*unif(i,1)-1)*999)+1;
        gaussian(i,1) = lookUp(index);
    %For U[0,1/2] we add 1/2 to make it U[1/2,1] and simpy invert LUT
    %value
    else
        index = round((2*(unif(i,1)+0.5)-1)*999)+1;
        gaussian(i,1) = -lookUp(index);
    end
        
end
subplot(2,1,1)
histogram(gauss)
title("\fontsize{20} Histogram of MATLAB generated Normal R.V.'s")
xlim([-5 5])
subplot(2,1,2)
histogram(gaussian)
title("\fontsize{20} Histogram of Normal R.V.'s Generated Using U[0,1] and Look-Up Table")
xlim([-5 5])


%% 
%parameters for quantization / LUT length / floor and ceiling for
%quantization
lutLength = 512;
quantBits = 12;
floorQuant = -3;
ceilingQuant = 3;
%generate x values for erfInv(x) and look up table of erfInv(x) values
x = linspace(-1,1,lutLength);
lookUpFinal = sqrt(2)*erfinv(x);
%plot unquantized table
subplot(3,1,1)
plot(lookUpFinal)
title('Look Up Table')
title("\fontsize{20} Unquantized LUT")
xlim([1 lutLength])
%define quantization levels and quantized LUT
quanta = 6 / (2^quantBits);
lookUp12bit = zeros(1,lutLength);
%loop through all quantization levels
for i = 1:4096
    %loop through nonquantized lookUp and add perform quantization
    for j = 1:length(lookUpFinal)
        if lookUpFinal(j) > (floorQuant + (i-1)*quanta) && lookUpFinal(j) < (floorQuant + i*quanta)
            lookUp12bit(j) = i;
        elseif lookUpFinal(j) <= floorQuant
            lookUp12bit(j) = 0;
        elseif lookUpFinal(j) >= ceilingQuant
            lookUp12bit(j) = 2^quantBits - 1;
        end
    end
end
%plot quantized table
subplot(3,1,2)
stem(lookUp12bit)
title(['\fontsize{20}' num2str(quantBits) '-Bit Quantized LUT with ' num2str(lutLength) ' Entries'])
xlim([1 lutLength])
%create final table by converting values to actual dac voltages for MCP4725
lookUpFinal = (lookUp12bit * (3.3/4095)) - 1.65;
%plot
subplot(3,1,3)
plot(lookUpFinal)
title(['\fontsize{20}' num2str(quantBits) '-Bit Quantized LUT with ' num2str(lutLength) ' Entries Converted to MCP4725 Output Voltages'])
xlim([1 lutLength])
%% Special Test Versions of the LUT
lookUp12bit = lookUp12bit - 2048;
lookUpFinal = lookUpFinal /5;


