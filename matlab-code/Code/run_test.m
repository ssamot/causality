function run_test(SS, MM)

    Feature_init; %Init all stuff, read data and file directories.

    % types              = {'train'}; %'train','valid'
    % types = {'trainpairssym'}; %'valid' %'trainpublicinfosym' %'traintargetsym %'trainpairssym'
    types = {'finalvalidpairs'}; %'finaltrainpairs','finaltrainpairssym','finalvalidpairs'

    T=length(types);

    S = str2num(SS);
    M = str2num(MM);	

    feature_name = 'final_lingam/'; %lingham, igci_uniform 
    algorithms={'_lingam.csv'};

    %algorithms={'_igci_uniform_entropy.csv'};
    %refMeasures={1};
    %estimators={1};

   % algorithms={'_igci_uniform_entropy.csv','_igci_uniform_integralApproximation.csv'};
   % refMeasures={1,1};
   % estimators={1,2};

 %   algorithms={'_igci_uniform_integralApproximation.csv'};
    refMeasures={1};
    estimators={2};

    numExperiments = length(algorithms);

    %Remove the loop and get values for algorithms, refMeasures and estimators
    %to get only 1 case:
    for experiment=1:numExperiments

        algorithm = algorithms{experiment};
	refMeasure = refMeasures{experiment};
	estimator = estimators{experiment};

        for k=1:T

            D=CEdata(dataname, types{k}, public_data_dir, private_data_dir)
            
            numTimeSeries = length(D.X); 
            
            startPoint = S;
            endPoint = S+M-1;
            realEndPoint = min(numTimeSeries,endPoint);
            
            F = zeros((realEndPoint-startPoint+1),1);
	    tsIdx = 1;

            for ts=startPoint:realEndPoint
                thisTimeSeriesX = D.X{ts}; 
                numPairs = length(thisTimeSeriesX);

                thisIsA = thisTimeSeriesX.A;
                thisIsB = thisTimeSeriesX.B;

                %thisIsA = thisIsA(1:min(5000,length(thisIsA)));
                %thisIsB = thisIsB(1:min(5000,length(thisIsB)));

                %F(tsIdx) = pnl(thisIsA,thisIsB,0.05);
                %F(ts) = gpi(thisIsA,thisIsB);
                F(ts) = lingam(thisIsA,thisIsB);
                %F(tsIdx) = UInd_KCItest(thisIsA,thisIsB);
                %F(ts) = numPairs;
            
		%F(ts) = igci(thisIsA,thisIsB,refMeasure,estimator);

		outputFile = [resu_dir '/' feature_name types{k} num2str(startPoint) '_to_' num2str(realEndPoint) algorithm];
                %outputFile = [resu_dir '/' feature_name types{k} startPoint '_to_' realEndPoint algorithm];
                fprintf(['Writing results to ' num2str(startPoint) '_to_' num2str(realEndPoint) types{k} algorithm]);
                fprintf(' (%d/%d): %.5f ... \n', ts, numTimeSeries, F(tsIdx));

		tsIdx = tsIdx + 1;
            end

            dlmwrite(outputFile, F);

        end
    end

return
