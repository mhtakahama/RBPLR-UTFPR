%% Leitor de arquivo .tdms do Labview para bancada RBPLR
clear all; echo off; close all force; clc; format long;tic; %clear another variables
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Universidade Tecnológica Federal do Paraná - Campus Curitiba
%Laboratório de Análise de Superfície de Contato - LASC
%Centro de Pesquisa em Reologia e Fluidos Não Newtonianos - CERNN

%Professor Tiago Cousseau
%Professor Cezar Otaviano Ribeiro Negrão

%Doutorando: Marcos Hiroshi Takahama

%dez 2021
%% 1.0 - pick file
%Pick file properties
[file_name,file_path] = uigetfile('*.*','Select a file tdsm to convert');
[~,file_title,~] = fileparts(file_name);
% addpath(file_path);

%Create a folder and save workspace
date_noww= datestr(now,'yyyymmddTHHMMSS'); %data atual
currentFolder = pwd; %informação da pasta onde este codigo se encontra
diretorio=[pwd '\arquivos\' file_title '\' date_noww]; %Diretorio geral
diretorio_cdg=[diretorio '\cdg100'];    %Diretorio apenas deste código
mkdir([diretorio_cdg]); %Cria diretório

%Cria um bkp do arquivo do editor atual
code_now = matlab.desktop.editor.getActiveFilename; %Pega informações deste código
copyfile(code_now,[diretorio_cdg '\bkp_cdg100.m']); %Cria uma cópia backup deste código

DATA_FULL=convertTDMS(0,[file_path '\' file_name]); %convert tdsm to workspace matlab
%% 2. Get data info (based in selections from file)

[m,n]=size({DATA_FULL.Data.MeasuredData.Name});

for i=3:n
    DATA_Date{i-2}={DATA_FULL.Data.MeasuredData(i).Property(1).Value}.'; %get data from date
    DATA_Names{i-2}={DATA_FULL.Data.MeasuredData(i).Name}.'; %get name
    DATA_Values{:,i-2}=DATA_FULL.Data.MeasuredData(i).Data; %get values
    DATA_Units{i-2}={DATA_FULL.Data.MeasuredData(i).Property(6).Value}.'; %Get unit
    DATA_aqs_rate{i-2}=round(1/[DATA_FULL.Data.MeasuredData(i).Property(3).Value].'); %Get aqs rate 1.652 nyqust
    
    if strcmp(cell2mat(DATA_Units{1,i-2}),'Nm')==1
        DATA_Values{:,i-2}=-DATA_Values{:,i-2};
    end
end

DATA_aqs_rate=cell2mat(DATA_aqs_rate); %Taxa de amostragem

temperaturas_orig(:,1:4)=[DATA_Values{:,1:4}]; %Temperatura
Tempo_temperatura=(1:length(DATA_Values{:,1}))/(DATA_aqs_rate(1)*3600); %Construção do vetor de tempo com a frequencia amostral

carga_orig=[DATA_Values{:,5}]; %Carga
Tempo_carga=(1:length(DATA_Values{:,5}))/(DATA_aqs_rate(5)*3600);

torque_orig=[DATA_Values{:,6}]; %Torque
Tempo_torque_orig=(1:length(DATA_Values{:,6}))/(DATA_aqs_rate(6)*3600);

clear DATA_FULL
% Redução de amostragem 1 ponto por segundo, vetor tempo em horas
%1652 pontos por segundo, vetor tempo em horas
Tempo_torque=downsample(Tempo_torque_orig',DATA_aqs_rate(6));
torque=downsample(torque_orig',DATA_aqs_rate(6));
torque=torque';
carga=downsample(carga_orig',DATA_aqs_rate(5));
carga=carga';
temperaturas(:,1)=downsample(temperaturas_orig(:,1)',DATA_aqs_rate(4));
temperaturas(:,2)=downsample(temperaturas_orig(:,2)',DATA_aqs_rate(4));
temperaturas(:,3)=downsample(temperaturas_orig(:,3)',DATA_aqs_rate(4));
temperaturas(:,4)=downsample(temperaturas_orig(:,4)',DATA_aqs_rate(4));
% temperaturas=temperaturas';
clear Tempo_torque_orig torque_orig carga_orig temperaturas_orig Tempo_temperatura Tempo_carga Tempo_torque_orig
% salvar_dados(:,3)=carga';
% salvar_dados(:,4)=temperaturas(:,1)';


[m,n]=size(temperaturas);
%% 3. Plot

% Temperaturas pontuais no tempo - Sinal original
figure %Abre uma nova janela para plotar gráfico no MATLAB
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
set(gcf,'Name',['1 - Temperaturas dos termopares'],'NumberTitle','off');
hold on
plot(Tempo_torque,temperaturas(1:length(Tempo_torque),1),'red','LineWidth',3); %Blindagem
hold on
plot(Tempo_torque,temperaturas(1:length(Tempo_torque),2),'magenta','LineWidth',3); %face da base rigida
hold on
plot(Tempo_torque,temperaturas(1:length(Tempo_torque),3),'yellow','LineWidth',3); %topo da base rigida
hold on
plot(Tempo_torque,temperaturas(1:length(Tempo_torque),4),'blue','LineWidth',3); %Temperatura ambiente
hold on
title('Evolução de temperaturas no Tempo','FontSize',20) %Nome no gráfico
xlabel('Tempo (horas)') %Texto no eixo X
ylabel('Temperatura (ºC)') %Texto no eixo Y
legend('Blindagem (Sinal original)','Face da Base Rígida (Sinal original)','Topo da Base Rígida (Sinal original)','Temperatura ambiente (Sinal original)')
% xlim([0 8]) %Limites gráficos no eixo X
% ylim([0 40]) %Limites gráficos no eixo Y
grid on %Linhas de grade no gráfico
saveas(gcf, [diretorio_cdg '\1_temperaturas_termopar.jpg']); %Salva a janela de plot no diretório do código
saveas(gcf, [diretorio_cdg '\1_temperaturas_termopar.fig']); %Salva a janela de plot no diretório do código


% Carga no tempo
figure
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
set(gcf,'Name',['2 - Carga (Sinal Original)'],'NumberTitle','off');
xlabel('Tempo (horas)')
ylabel('Carga (kN)')
title('Evolução de Carga no Tempo','FontSize',20) %Legend options
hold on
plot(Tempo_torque,carga,'red'); %Blindagem
grid on
ylim([0 3])
grid on
saveas(gcf, [diretorio_cdg '\2 - Carga_sinal_original.jpg']);
saveas(gcf, [diretorio_cdg '\2 - Carga_sinal_original.fig']);
% savefig([diretorio_cdg '\2 - Carga_sinal_original.fig'])


% Torque no tempo
figure
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
set(gcf,'Name',['3 - Torque (Sinal Original)'],'NumberTitle','off');
xlabel('Tempo (horas)')
ylabel('Torque (N.m)')
title('Evolução de Torque no Tempo','FontSize',20) %Legend options
hold on
plot(Tempo_torque,torque,'red'); %Blindagem
[media_30min_torque]=media_30min(Tempo_torque,torque)
annotation('textbox',[0.2 0.4 0.2 0.4],...
          'String',{['Experimental últimos 30min: '] [num2str(media_30min_torque,3) ' N.m']},...
                        'FontSize',14,...
                        'FontName','Arial',...
                        'LineStyle','-',...
                        'EdgeColor',[1 1 0],...
                        'LineWidth',2,...
                        'BackgroundColor',[0.9  0.9 0.9],...
                        'Color',[0.84 0.16 0]);
                    
grid on
saveas(gcf, [diretorio_cdg '\3 - Torque_sinal_original.jpg']);
saveas(gcf, [diretorio_cdg '\3 - Torque_sinal_original.fig']);
% savefig([diretorio_cdg '\3 - Torque_sinal_original.fig'])


%% Torque vs temperatura
figure
set(gcf,'Name',['4 - Torque vs Temperatura'],'NumberTitle','off');
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
title('Torque x Temperatura','FontSize',20) %Legend options

yyaxis left
hold on
plot(Tempo_torque,torque/4,'black','LineWidth',3); %Blindagem
hold on
% legend('Célula de Torque','Torque viscoso médio','Torque viscoso malha')
% legend('Célula de Torque','Modelo proposto','Modelo proposto carga 2x','Modelo proposto carga 3x','Houpert','SKF','','FontSize',20)
ylabel('Torque (N.m)','FontSize',20)
xlabel('Tempo (horas)','FontSize',20)
ylim([0 0.5])
xlim([0 8])
hold on

yyaxis right
plot(Tempo_torque,temperaturas(1:length(Tempo_torque),1),'color',[0.4660 0.6740 0.1880],'LineWidth',3); %Referencia 
ylabel('Temperatura (°C)','FontSize',20,'color',[0.4660 0.6740 0.1880])
hold on
grid minor
% legend('Célula de Torque','Modelo proposto','Modelo proposto carga 2x','Houpert','SKF','FontSize',20)
legend('Torque medido','Temperatura medida','FontSize',20)
hold on
saveas(gcf, [diretorio_cdg '\4 - TorquevsTemperatura.jpg']);
saveas(gcf, [diretorio_cdg '\4 - TorquevsTemperatura.fig']);


%% Temperaturas corrigidas

    [temperatura1_cor,temperatura2_cor,temperatura3_cor,temperatura4_cor]=ajuste_temperatura(temperaturas(1:length(Tempo_torque),1),temperaturas(1:length(Tempo_torque),2),temperaturas(1:length(Tempo_torque),3),temperaturas(1:length(Tempo_torque),4));


% Temperaturas pontuais no tempo - Sinal original
figure %Abre uma nova janela para plotar gráfico no MATLAB
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
set(gcf,'Name',['5 - Correção termopar blindagem'],'NumberTitle','off');
hold on
plot(Tempo_torque,temperaturas(1:length(Tempo_torque),1),'red','LineWidth',3); %Blindagem
hold on
plot(Tempo_torque,temperatura1_cor,'black','LineWidth',3); %face da base rigida
hold on
title('Evolução de temperaturas no Tempo','FontSize',20) %Nome no gráfico
xlabel('Tempo (horas)') %Texto no eixo X
ylabel('Temperatura (ºC)') %Texto no eixo Y
legend('Blindagem (Sinal original)','Temperatura ambiente (Sinal corrigido)')
% xlim([0 8]) %Limites gráficos no eixo X
% ylim([0 40]) %Limites gráficos no eixo Y
grid on %Linhas de grade no gráfico
% savefig(gcf,[diretorio_cdg '\5_temperaturas_termopar.jpg'])
% savefig(gcf,[diretorio_cdg '\1_temperaturas_termopar.fig'])
% 
%% 4. Exportar dados para .csv

salvar_dados2(:,1)=Tempo_torque(1:length(Tempo_torque));
salvar_dados2(:,2)=torque(1:length(Tempo_torque));
salvar_dados2(:,3)=carga(1:length(Tempo_torque));
salvar_dados2(:,4)=temperatura1_cor;
salvar_dados2(:,5)=temperatura2_cor;
salvar_dados2(:,6)=temperatura3_cor;
salvar_dados2(:,7)=temperatura4_cor;


csvwrite([diretorio_cdg '\dados_experimentais.txt'],salvar_dados2)

tempo_cdg=toc/60;%Tempo para rodar o codigo

warndlg(sprintf(['Tudo pronto, Tempo de execução: ' num2str(tempo_cdg,2) ' min']));
% winopen(diretorio_cdg);
%%


%dados necessarios para preencher tabela
%dia
DATA_Date{1}
%torque rp
[media_30min_torque]=media_30min(Tempo_torque,torque/4)
%T1
temperatura_inicial=temperatura1_cor(1)
%Tend-t1
[media_30min_temperaturas]=media_30min(Tempo_torque,temperatura1_cor);
delta_temperatura=media_30min_temperaturas-temperatura1_cor(1)
% warndlg(sprintf(' Tudo pronto '));
%% 17 - Valor médio de uma propriedade nos últimos 30minutos de ensaio
function [media_30min_torque]=media_30min(tempo_exp,torque_exp)
% cálculo da média de torque nos ultimos 30min de ensaio
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
media_30min_torque1=soma_torque/cont_torque;
media_30min_torque=mean(torque_exp(end-cont_torque:end));
desvio_30min_torque=std(torque_exp(end-cont_torque:end));
end