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


function [Leader_score,Leader_pos,Convergence_curve]=IPO(SearchAgents_no,areas,parties,Max_iter,lb,ub,dim,fobj)

% initialize position vector and score for the leader
Leader_pos=zeros(1,dim);
Leader_score=inf; %change this to -inf for maximization problems

%Initialize the positions of search agents
Positions=initialization(SearchAgents_no,dim,ub,lb);
auxPositions = Positions;
prevPositions = Positions;

%Initial fitness computation
fitness=zeros(SearchAgents_no, 1)+inf;
for i=1:size(Positions,1)
    %Calculate objective function for each search agent
    fitness(i,1)=fobj(Positions(i,:));
    %Update the leader
    if fitness(i,1)<Leader_score % Change this to > for maximization problem
        Leader_score=fitness(i,1);
        Leader_pos=Positions(i,:);
    end
end
auxFitness = fitness;
prevFitness = fitness;

%Declaring convergence curve
Convergence_curve=zeros(1,Max_iter);

%Finding party leaders and area winners
aWinnerInd=zeros(areas,1);   %Indices of area winners in x
aWinners = zeros(areas,dim); %Area winners are stored separately
for a = 1:areas
    [aWinnerFitness,aWinnerParty]=min(fitness(a:areas:SearchAgents_no));
    aWinnerInd(a,1) = (aWinnerParty-1) * areas + a;
    aWinners(a,:) = Positions(aWinnerInd(a,1),:);
end

%Finding party leaders
pLeaderInd=zeros(parties,1);    %Indices of party leaders in x
pLeaders = zeros(parties,dim);  %Positions of party leaders in x
for p = 1:parties
    pStIndex = (p-1) * areas + 1;
    pEndIndex = pStIndex + areas - 1;
    [partyLeaderFitness,leadIndex]=min(fitness(pStIndex:pEndIndex));
    pLeaderInd(p,1) = (pStIndex - 1) + leadIndex; %Indexof party leader
    pLeaders(p,:) = Positions(pLeaderInd(p,1),:);
end

%Main Loop
t=0;% Loop counter
while t<Max_iter
    for SA = 1:SearchAgents_no
        if fitness(SA, 1) < auxFitness(SA, 1)
            prevFitness(SA, 1) = auxFitness(SA, 1);
            prevPositions(SA, :) = auxPositions(SA, :);
            auxFitness(SA, 1) = fitness(SA, 1);
            auxPositions(SA, :) = Positions(SA, :);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%% Election campaign %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for a = 1:areas
        for p = 1:parties
            i = (p-1)*areas + a; %index of member
            
            for j=1:dim
                if rand() < (1-t/Max_iter)
                    continue;
                else
                    center = (pLeaders(p,j) + aWinners(a,j) ) / 2 ;
                end
                
                %Cases of Eq. 9 in paper
                if prevFitness(i) >= fitness(i)
                    if (prevPositions(i,j) <= Positions(i,j) && Positions(i,j) <= center) ...
                            || (prevPositions(i,j) >= Positions(i,j) && Positions(i,j) >= center)
                        
                        radius = center - Positions(i,j);
                        Positions(i,j) = center + rand() * radius;
                    elseif (prevPositions(i,j) <= Positions(i,j) && Positions(i,j) >= center && center >= prevPositions(i,j)) ...
                            || (prevPositions(i,j) >= Positions(i,j) && Positions(i,j) <= center && center <= prevPositions(i,j))
                        
                        radius = abs(Positions(i,j) - center);
                        Positions(i,j) = center + (2*rand()-1) * radius;
                    elseif (prevPositions(i,j) <= Positions(i,j) && Positions(i,j) >= center && center <= prevPositions(i,j)) ...
                            || (prevPositions(i,j) >= Positions(i,j) && Positions(i,j) <= center && center >= prevPositions(i,j))
                        
                        radius = abs(prevPositions(i,j) - center);
                        Positions(i,j) = center + (2*rand()-1) * radius;
                    end
                    
                    %Cases of Eq. 10 in paper
                elseif prevFitness(i) < fitness(i)
                    if (prevPositions(i,j) <= Positions(i,j) && Positions(i,j) <= center) ...
                            || (prevPositions(i,j) >= Positions(i,j) && Positions(i,j) >= center)
                        
                        
                        radius = abs(Positions(i,j) - center);
                        Positions(i,j) = center + (2*rand()-1) * radius;
                    elseif (prevPositions(i,j) <= Positions(i,j) && Positions(i,j) >= center && center >= prevPositions(i,j)) ...
                            || (prevPositions(i,j) >= Positions(i,j) && Positions(i,j) <= center && center <= prevPositions(i,j))
                        
                        radius = Positions(i,j) - prevPositions(i,j);
                        Positions(i,j) = prevPositions(i,j) + rand() * radius;
                    elseif (prevPositions(i,j) <= Positions(i,j) && Positions(i,j) >= center && center <= prevPositions(i,j)) ...
                            || (prevPositions(i,j) >= Positions(i,j) && Positions(i,j) <= center && center >= prevPositions(i,j))
                        center2 = prevPositions(i,j);
                        radius = abs(center - center2);
                        Positions(i,j) = center + (2*rand()-1) * radius;
                    end
                end
                
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%% Party switching Phase %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for p=1:parties
        for a=1:areas
            fromPInd = (p-1)*areas + a;
            if rand() < (1/SearchAgents_no)
                %Selecting a party other than current where want to send the
                %member
                toParty = randi(parties);
                while(toParty == p)
                    toParty = randi(parties);
                end
                
                %Deciding member in TO party
                toPStInd = (toParty-1) * areas + 1;
                toPInd = toPStInd + randi(areas)-1;
                
                
                %Deciding what to do with member in FROM party and switching
                fromPInd = (p-1)*areas + a;
                temp = Positions(toPInd,:);
                Positions(toPInd,:) = Positions(fromPInd,:);
                Positions(fromPInd,:)=temp;
                
                temp = fitness(toPInd);
                fitness(toPInd) = fitness(fromPInd);
                fitness(fromPInd) = temp;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%Election Phase%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:size(Positions,1)
        % Return back the search agents that go beyond the boundaries of the search space
        Flag4ub=Positions(i,:)>ub;
        Flag4lb=Positions(i,:)<lb;
        Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
        
        %Calculate objective function for each search agent
        fitness(i,1)=fobj(Positions(i,:));
        if fitness(i, 1) >= auxFitness(i, 1)
            fitness(i, 1) = auxFitness(i, 1);
            Positions(i, :) = auxPositions(i, :);
        end
        
        %Update the leader
        if fitness(i,1)<Leader_score % Change this to > for maximization problem
            Leader_score=fitness(i,1);
            Leader_pos=Positions(i,:);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%% Govt. Formation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Finding area winners
    for a = 1:areas
        [aWinnerFitness,aWinnerParty]=min(fitness(a:areas:SearchAgents_no));
        aWinnerInd(a,1) = (aWinnerParty-1) * areas + a;
        aWinners(a,:) = Positions(aWinnerInd(a,1),:);
    end
    %Finding party leaders
    for p = 1:parties
        pStIndex = (p-1) * areas + 1;
        pEndIndex = pStIndex + areas - 1;
        [partyLeaderFitness,leadIndex]=min(fitness(pStIndex:pEndIndex));
        pLeaderInd(p,1) = (pStIndex - 1) + leadIndex; %Indexof party leader
        pLeaders(p,:) = Positions(pLeaderInd(p,1),:);
    end
    %%%%%%%%%%%%%%%%%%%%% Parliamentarism %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for a=1:areas
        newAWinner = aWinners(a,:);
        i = aWinnerInd(a);
        
        for j = 1:dim
            if rand() < (1-t/Max_iter)
                continue;
            end
            distance = abs(Leader_pos(1,j) - newAWinner(1,j));
            newAWinner(1,j) = newAWinner(1,j) + (2*rand()-1) * distance;
        end
        % Return back the search agents that go beyond the boundaries of the search space
        Flag4ub=newAWinner(1,:)>ub;
        Flag4lb=newAWinner(1,:)<lb;
        newAWinner(1,:)=(newAWinner(1,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
        
        newAWFitness=fobj(newAWinner(1,:));
        
        %Replace only if improves
        if newAWFitness < fitness(i)
            Positions(i,:) = newAWinner(1,:);
            fitness(i,1) = newAWFitness;
            aWinners(a,:) = newAWinner(1,:);
            if pLeaderInd(ceil(i / areas),1) == i
                pLeaders(ceil(i / areas), :) = newAWinner(1,:);
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    t=t+1;
    Convergence_curve(t)=Leader_score;
    [t Leader_score];
end

