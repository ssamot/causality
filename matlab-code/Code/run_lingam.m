function run_lingam(set)

    Feature_init; %Init all stuff, read data and file directories.

    file = 'finalvalidpairs';
    if strcmp(set,'valid')
      	file = 'final_valid';
    elseif strcmp(set,'train')
    	file = 'final_train';
    else
	file = set;
    end 

    T=1;
    feature_name = './';  
    algorithms={'_lingam.csv'};

    numExperiments = length(algorithms);

    %Remove the loop and get values for algorithms, refMeasures and estimators
    %to get only 1 case:
    for experiment=1:numExperiments

        algorithm = algorithms{experiment};

        for k=1:T

            D=CEdata(dataname, file, public_data_dir, private_data_dir)
            numTimeSeries = length(D.X); 
	    tsIdx = 1;
            
	    for ts=1:numTimeSeries
                thisTimeSeriesX = D.X{ts}; 
                numPairs = length(thisTimeSeriesX);

                thisIsA = thisTimeSeriesX.A;
                thisIsB = thisTimeSeriesX.B;

                F(ts) = lingam(thisIsA,thisIsB);

		outputFile = [resu_dir '/' feature_name set algorithm];
                fprintf(['Writing results to Models/Matlab/' set algorithm]);
                fprintf(' (%d/%d): %.5f ... \n', ts, numTimeSeries, F(tsIdx));

		tsIdx = tsIdx + 1;
            end

	    F = F';
            dlmwrite(outputFile, F);

        end
    end

return
