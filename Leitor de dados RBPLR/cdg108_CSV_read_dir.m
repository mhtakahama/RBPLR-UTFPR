close all force; clear all; clc; format long; tic
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ALGORITM TO READ FILES FROM ROLLING BEARING POWER LOSS TEST RIG
%Marcos Takahama - PhD. Student
%Pedro Lucas - Master degree Student
%Matheus Bonote - Graduation Student
%% Federal University of Technology - Paraná (UTFPR)
%Campus Curitiba
%Laboratório de Análise de Superfície de Contato - LASC
%Professor Tiago Cousseau

%% 1.0 - pick file
%Pick file properties
[dir_path] = uigetdir('*.*','Select a dir tdsm to convert');
addpath(dir_path);
list_files = dir(dir_path);
all_files = {list_files.name};
total_files=length(all_files);
extension='.csv'; %extensão desejada
cont=0;

for file_cont=1:total_files
    [file_path,file_name,ext] = fileparts([dir_path '\' all_files{file_cont}]);
    tf = strcmp(extension,ext) %compara extensões
    
    if tf==1
        
        DATA_FULL=readmatrix([file_path '\' file_name ext]); %Read CSV File
        cont=cont+1;      

        Name_file{cont,:}=file_name;
        Torque_RP(cont,1)=DATA_FULL(2);
        Temp_Inicial(cont,1)=DATA_FULL(3);
        Temp_RP(cont,1)=DATA_FULL(4);
        Temp_delta(cont,1)=DATA_FULL(5);
        RPM_Check(cont,1)=DATA_FULL(6);
        
    end
    
    %Clear data temporary data read\
    clear DATA_FULL
end
tempo_cdg=toc/60;%Tempo para rodar o codigo
warndlg(sprintf(['Tudo pronto, Tempo de execução: ' num2str(tempo_cdg,2) ' min']));
