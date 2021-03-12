%_________________________________________________________________________________
%  Improved Political Optimizer for Complex Landscapes and Engineering 
%  Optimization Problems source codes version 1.0
%
%  Developed in MATLAB R2015a
%
%  Author and programmer: Qamar Askari
%
%         e-Mail: l165502@lhr.nu.edu.pk
%                 syedqamar@gift.edu.pk
%
%
%   Main paper:
%   Askari, Q. & Younas, I. (2021). Improved Political Optimizer for 
%   Complex Landscapes and Engineering Optimization Problems
%   Expert Systems with Applications, 2021, 
%____________________________________________________________________________________

clear all
clc

%BenchmarkType 1 for CEC2017 and 2 for CEC2014
fromBenchmarkType = 1;
toBenchmarkType = 1;

Max_FEV = 40000;        %Maximum number of function evaluations
areas = 20;
parties = 5;
SearchAgents_no = parties * areas;
Max_iteration= round(Max_FEV / (SearchAgents_no+areas));
runs = 25;               %Total no. of runs

for benchmarksType = fromBenchmarkType:toBenchmarkType
    if benchmarksType == 1
        maxFunc = 30;
        sheetName = 'CEC2017';  %Please rename "input_data2017" folder to "input_data"
    elseif benchmarksType == 2
        maxFunc = 30;
        sheetName = 'CEC2014';  %Please rename "input_data2014" folder to "input_data"
    else
        exit;
    end
    
    for fn = 1:30
        Function_name=strcat('F',num2str(fn));
        if benchmarksType == 1
            if fn == 2
                continue;   %To skip function-2 of CEC-BC-2017 because of its unstable behavior
            end
            [lb,ub,dim,fobj]=CEC2017(Function_name);
        elseif benchmarksType == 2
            [lb,ub,dim,fobj]=CEC2014(Function_name);
        end
        
        % Calling algorithm
        Best_score_T = zeros(runs,1);
        AvgConvCurve = zeros(1,Max_iteration);
        display (['Function:   ', num2str(fn)]);
        for run=1:runs
            [Best_score_0, Best_pos, cg_curve]=IPO(SearchAgents_no,areas,parties,Max_iteration,lb,ub,dim,fobj);
            Best_score_T(run) = Best_score_0;
            size(cg_curve);
            Best_score_0;
            Best_pos;
            AvgConvCurve = AvgConvCurve + cg_curve;
            
            display(['Run: ', num2str(run), '         ', 'Fitness: ', num2str(Best_score_0), '     ', 'Position:      ', num2str(Best_pos)]);
        end
        %pause
        Best_score_Best = min(Best_score_T);
        Best_score_Worst = max(Best_score_T);
        Best_score_Median = median(Best_score_T);
        Best_Score_Mean = mean(Best_score_T);
        Best_Score_std = std(Best_score_T);
        AvgConvCurve = AvgConvCurve ./ runs;
        
        format long
        display(['Median:  ', num2str(Best_score_Median), '     ', 'Mean:  ', num2str(Best_Score_Mean), '     ', 'Std. Deviation:  ', num2str(Best_Score_std)]);
        
    end
    
end