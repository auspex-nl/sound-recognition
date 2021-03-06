%% Sound Recognition script
% Some description text goes here
% And some more will go here. Great

%% Getting a list of training files
% This will get a list of all training files and properly classifies them
training_files_music = recursive_list_files('D:\matlab\sounds\training\music','music');
training_files_speech = recursive_list_files('D:\matlab\sounds\training\speech','speech');

X = zeros(size(training_files_music,1)*40,10);
Y = cell(size(training_files_music,1)*40,1);

X2 = zeros(size(training_files_music,1)*40,10);
Y2 = cell(size(training_files_music,1)*40,1);

%% Define filters
% Define some filters to use with Haar-Like recognition
Wfilters = [2,4,6,8,10,12,14,16,18,20];

%% Calculating Haar-Like filter values
% Per file the Haar-Like filter values calculated

fprintf('music')
for i=1:size(training_files_music,1)    
    [samples, info, framesize ] = read_wav_file(cell2mat(training_files_music(i,2)),40);
        
    Xmi = calculate_haar(samples,Wfilters);

    X((i-1)*size(Xmi,1)+1:(i)*size(Xmi,1),:) = Xmi;
    %X(i,:) = Xmi;
    %Y(i) = {'music'};
    %Y((i-1)*size(Xmi,1)+1:(i)*size(Xmi,1)) = {'music'};
    Y((i-1)*size(Xmi,1)+1:(i)*size(Xmi,1)) = {'music'};
    fprintf('.');
end

fprintf('done\n\n');
fprintf('speech');

for i=1:size(training_files_speech,1)    
    [samples, info, framesize ] = read_wav_file(cell2mat(training_files_speech(i,2)),40);
        
    Xmi = calculate_haar(samples,Wfilters);
    X2((i-1)*size(Xmi,1)+1:(i)*size(Xmi,1),:) = Xmi;    
    %X2(i,:) = Xmi;
    %Y2(i) = {'speech'};   
    Y2((i-1)*size(Xmi,1)+1:(i)*size(Xmi,1)) = {'speech'};
    %Y2((i-1)*size(Xmi,1)+1:(i)*size(Xmi,1)) = {'speech'};
    fprintf('.');
end

fprintf('done\n\n');


Y1 = cell(size(X,1),1);
Y2 = cell(size(X2,1),1);

Y1(:) = {'music'};
Y2(:) = {'speech'};

X = [X ; X2];
Y = [Y1 ; Y2];



%testvalues = sum(strcmp('music',Y));
%testvalues2 = sum(strcmp('speech',Y));

%fprintf('size X: %dx%d, size Y: %dx%d\n size testvalue1:%d, size testvalue2: %d\n\n',size(X,1),size(X,2),size(Y,1),size(Y,2),testvalues,testvalues2);

%% Creating the K-Nearest-Neighbours Model
% The Haar-Like features are now used to create a KNN Model, so sound
% samples can be tested against the model later on.
fprintf('generating model...');
mdl = create_knn_model(X,Y,1);
fprintf('done\n\n');

%% Getting a list of test files
% Getting a list of test files now
test_files = recursive_list_files('D:\matlab\sounds\test','test');

%% Test every testfile 1-by-1 against the model
% Classify according to what class most frames belong to
for i=1:size(test_files,1) 

    [samples, info, framesize ] = read_wav_file(cell2mat(test_files(i,2)),40);
    Xmtest = calculate_haar(samples,Wfilters);
    
   
    values = cell(1,size(Xmtest,1));
   
    for it = 1:size(Xmtest,1)
        %ivalue = predict(mdl,Xmtest(it,:));
        values(it) = predict(mdl,Xmtest(it,:));

        %fprintf('test %d: %s\n', it, cell2mat(predict(mdl, Xmtest(it,:)))); 
        %Xmtest(i,:)
    end

    testvalues = strcmp('music',values);

    fprintf('Test: %s, Music: %3.1f%%, Speech: %3.1f%%\n',info.Filename,(sum(testvalues)/size(testvalues,2))*100,((size(testvalues,2)-sum(testvalues))/size(testvalues,2))*100);

    
end
