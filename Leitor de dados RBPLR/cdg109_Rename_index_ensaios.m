close all force; clear all; clc; format long; tic
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Federal University of Technology - Paran� (UTFPR)
%Campus Curitiba
%Laborat�rio de An�lise de Superf�cie de Contato - LASC
%Centro de Pesquisa em Reologia e Fluidos N�o Newtonianos - CERNN

nome='P';
%% 1.0 - pick dir
%Pick file properties
[dir_path] = uigetdir('*.*','Select a dir tdsm to convert');
addpath(dir_path);
list_files = dir(dir_path);
all_files = {list_files.name};
total_files=length(all_files);
extension='.tdms'; %extens�o desejada
% 
% date_noww= datestr(now,'yyyymmddTHHMMSS'); %data atual
% currentFolder = pwd; %informa��o da pasta onde este codigo se encontra
% diretorio_raiz= [pwd '\arquivos\' date_noww]; %Diretorio geral
% mkdir([diretorio_raiz])

% code_now = matlab.desktop.editor.getActiveFilename; %Pega informa��es deste c�digo
% [~,code_now_file_name,~] = fileparts(code_now);
% copyfile(code_now,[dir_path '\bkp_' code_now_file_name '.m']); %Cria uma c�pia backup deste c�digo

indexador=0;
for file_cont=1:total_files
    [file_path,file_name,ext] = fileparts([dir_path '\' all_files{file_cont}]);
    tf = strcmp(extension,ext) %compara extens�es
    if tf==1
        indexador=indexador+1;

        nomeAntigo = file_name;

        % Crie o novo nome do arquivo adicionando um n�mero ao final
        novoNome = sprintf('%s%d-%s',nome, indexador, nomeAntigo); % O n�mero � a posi��o do arquivo na lista

        % Renomeie o arquivo
        movefile(fullfile(file_path, [nomeAntigo ext]), fullfile(file_path, [novoNome ext]));

    end
end

tempo_cdg=toc/60;%Tempo para rodar o codigo
warndlg(sprintf(['Tudo pronto, Tempo de execu��o: ' num2str(tempo_cdg,2) ' min']));
winopen(dir_path);
