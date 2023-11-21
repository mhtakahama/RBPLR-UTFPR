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
    tf = strcmp(extension,ext); %compara extensões
    
    if tf==1
        DATA_FULL=readtable([file_path '\' file_name ext]); %Read CSV File
        cont=cont+1;      
        
        index(cont)=cont;
        Data(cont)=DATA_FULL.Data(1);
        nome_arquivo{cont}=file_name;
        if DATA_FULL.TorqueRP(1)<0
            DATA_FULL.TorqueRP(1)=DATA_FULL.TorqueRP(1)*-1;
        end
        TorqueRP(cont)=DATA_FULL.TorqueRP(1);
        
        T_inicial(cont)=DATA_FULL.T_inicial(1);
        T_RP(cont)=DATA_FULL.T_RP(1);
        T_Delta(cont)=DATA_FULL.T_Delta(1);
        RPM_check(cont)=DATA_FULL.RPM_check(1);
       
    end
    
    %Clear data temporary data read\
    clear DATA_FULL

    
end


Get_properties = table(index', Data',nome_arquivo',TorqueRP',T_inicial',T_RP',T_Delta',RPM_check');
Get_properties.Properties.VariableNames([1:8]) = {'Index' 'Data' 'Nome_arquivo' 'TorqueRP' 'T_inicial' 'T_RP' 'T_Delta' 'RPM_check'};
B = sortrows(Get_properties,'Data');


tempo_cdg=toc/60;%Tempo para rodar o codigo
warndlg(sprintf(['Tudo pronto, Tempo de execução: ' num2str(tempo_cdg,2) ' min']));
winopen(dir_path);
