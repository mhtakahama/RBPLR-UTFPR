%% Leitor de arquivo .tdms do Labview para bancada RBPLR
clear all; echo off; close all force; clc; format long;tic; %clear another variables
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Universidade Tecnol�gica Federal do Paran� - Campus Curitiba
%Laborat�rio de An�lise de Superf�cie de Contato - LASC
%Centro de Pesquisa em Reologia e Fluidos N�o Newtonianos - CERNN

%Professor Tiago Cousseau
%Professor Cezar Otaviano Ribeiro Negr�o

%Doutorando: Marcos Hiroshi Takahama

%dez 2021
%% 1.0 - pick file
%Pick file properties
[file_name,file_path] = uigetfile('*.*','Select a file csv to read');
[~,file_title,~] = fileparts(file_name);
% addpath(file_path);

%Create a folder and save workspace
date_now= datestr(now,'yyyymmddTHHMMSS'); %data atual
date_noww= (['Data_' date_now(7:8) '_' date_now(5:6) '_' date_now(1:4) '_Horario_'  date_now(10:11) '_' date_now(12:13) '_' date_now(14:15)])
currentFolder = pwd; %informa��o da pasta onde este codigo se encontra
diretorio=[pwd '\arquivos\' file_title '\' date_noww]; %Diretorio geral
diretorio_cdg=[diretorio '\cdg100'];    %Diretorio apenas deste c�digo
mkdir([diretorio_cdg]); %Cria diret�rio

%Cria um bkp do arquivo do editor atual
code_now = matlab.desktop.editor.getActiveFilename; %Pega informa��es deste c�digo
copyfile(code_now,[diretorio_cdg '\bkp_cdg100.m']); %Cria uma c�pia backup deste c�digo

%% 2. - Extrai os dados do csv

dados = readtable([file_path file_name]);

Tempo_temperatura=dados{:,1};
torque=dados{:,2};
carga=dados{:,3};
temperaturas=dados{:,4};

[m,n]=size(temperaturas);
%% 3. Plot

% Temperaturas pontuais no tempo - Sinal original
figure %Abre uma nova janela para plotar gr�fico no MATLAB
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
set(gcf,'Name',['1 - Temperaturas dos termopares'],'NumberTitle','off');
hold on
plot(Tempo_temperatura,temperaturas(:,1),'red','LineWidth',3); %Blindagem
hold on
title('Evolu��o de temperaturas no Tempo','FontSize',20) %Nome no gr�fico
xlabel('Tempo (horas)') %Texto no eixo X
ylabel('Temperatura (�C)') %Texto no eixo Y
legend('Blindagem (Sinal original)','Face da Base R�gida (Sinal original)','Topo da Base R�gida (Sinal original)','Temperatura ambiente (Sinal original)')
xlim([0 8]) %Limites gr�ficos no eixo X
% ylim([0 40]) %Limites gr�ficos no eixo Y
grid on %Linhas de grade no gr�fico
saveas(gcf, [diretorio_cdg '\1_temperaturas_termopar.jpg']); %Salva a janela de plot no diret�rio do c�digo
% savefig([diretorio_cdg '\1_temperaturas_termopar.fig'])


% Carga no tempo
figure
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
set(gcf,'Name',['2 - Carga (Sinal Original)'],'NumberTitle','off');
xlabel('Tempo (horas)')
ylabel('Carga (kN)')
title('Evolu��o de Carga no Tempo','FontSize',20) %Legend options
hold on
plot(Tempo_temperatura,carga,'red'); %Blindagem
grid on
ylim([0 3])
grid on
saveas(gcf, [diretorio_cdg '\2 - Carga_sinal_original.jpg']);
% savefig([diretorio_cdg '\2 - Carga_sinal_original.fig'])


% Torque no tempo
figure
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
set(gcf,'Name',['3 - Torque (Sinal Original)'],'NumberTitle','off');
xlabel('Tempo (horas)')
ylabel('Torque (N.m)')
title('Evolu��o de Torque no Tempo','FontSize',20) %Legend options
hold on
plot(Tempo_temperatura,torque,'red'); %Blindagem
[media_30min_torque]=media_30min(Tempo_temperatura,torque)
annotation('textbox',[0.2 0.4 0.2 0.4],...
          'String',{['Experimental �ltimos 30min: '] [num2str(media_30min_torque,3) ' N.m']},...
                        'FontSize',14,...
                        'FontName','Arial',...
                        'LineStyle','-',...
                        'EdgeColor',[1 1 0],...
                        'LineWidth',2,...
                        'BackgroundColor',[0.9  0.9 0.9],...
                        'Color',[0.84 0.16 0]);
                    
grid on
saveas(gcf, [diretorio_cdg '\3 - Torque_sinal_original.jpg']);
% savefig([diretorio_cdg '\3 - Torque_sinal_original.fig'])

 
tempo_cdg=toc/60;%Tempo para rodar o codigo
warndlg(sprintf(['Tudo pronto, Tempo de execu��o: ' num2str(tempo_cdg,2) ' min']));


%% 17 - Valor m�dio de uma propriedade nos �ltimos 30minutos de ensaio
function [media_30min_torque]=media_30min(tempo_exp,torque_exp)
% c�lculo da m�dia de torque nos ultimos 30min de ensaio
tempo_em_horas=0.5;
tempo_30min_torque=tempo_exp(end)-tempo_em_horas; %

% varedura
soma_torque=0;
cont_torque=0;
for i=1:length(tempo_exp)
    if tempo_exp(i)>=tempo_30min_torque
    soma_torque=soma_torque+torque_exp(i);
    cont_torque=cont_torque+1;
    end
end
media_30min_torque1=soma_torque/cont_torque
media_30min_torque=mean(torque_exp(end-cont_torque:end))
desvio_30min_torque=std(torque_exp(end-cont_torque:end))
end