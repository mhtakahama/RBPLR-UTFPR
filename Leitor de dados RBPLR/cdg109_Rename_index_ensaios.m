close all force; clear all; clc; format long; tic
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Federal University of Technology - Paraná (UTFPR)
%Campus Curitiba
%Laboratório de Análise de Superfície de Contato - LASC
%Centro de Pesquisa em Reologia e Fluidos Não Newtonianos - CERNN

nome='P';
%% 1.0 - pick dir
%Pick file properties
[dir_path] = uigetdir('*.*','Select a dir tdsm to convert');
addpath(dir_path);
list_files = dir(dir_path);
all_files = {list_files.name};
total_files=length(all_files);
extension='.tdms'; %extensão desejada
% 
% date_noww= datestr(now,'yyyymmddTHHMMSS'); %data atual
% currentFolder = pwd; %informação da pasta onde este codigo se encontra
% diretorio_raiz= [pwd '\arquivos\' date_noww]; %Diretorio geral
% mkdir([diretorio_raiz])

% code_now = matlab.desktop.editor.getActiveFilename; %Pega informações deste código
% [~,code_now_file_name,~] = fileparts(code_now);
% copyfile(code_now,[dir_path '\bkp_' code_now_file_name '.m']); %Cria uma cópia backup deste código

indexador=0;
for file_cont=1:total_files
    [file_path,file_name,ext] = fileparts([dir_path '\' all_files{file_cont}]);
    tf = strcmp(extension,ext) %compara extensões
    if tf==1
        indexador=indexador+1;

        nomeAntigo = file_name;

        % Crie o novo nome do arquivo adicionando um número ao final
        novoNome = sprintf('%s%d-%s',nome, indexador, nomeAntigo); % O número é a posição do arquivo na lista

        % Renomeie o arquivo
        movefile(fullfile(file_path, [nomeAntigo ext]), fullfile(file_path, [novoNome ext]));

    end
end

tempo_cdg=toc/60;%Tempo para rodar o codigo
warndlg(sprintf(['Tudo pronto, Tempo de execução: ' num2str(tempo_cdg,2) ' min']));
winopen(dir_path);
