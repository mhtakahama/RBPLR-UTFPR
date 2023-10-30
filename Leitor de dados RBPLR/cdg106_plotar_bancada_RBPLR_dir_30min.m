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
extension='.tdms'; %extensão desejada

date_noww= datestr(now,'yyyymmddTHHMMSS'); %data atual
currentFolder = pwd; %informação da pasta onde este codigo se encontra
diretorio_raiz= [pwd '\arquivos\' date_noww]; %Diretorio geral
mkdir([diretorio_raiz])

code_now = matlab.desktop.editor.getActiveFilename; %Pega informações deste código
copyfile(code_now,[diretorio_raiz '\bkp_cdg.m']); %Cria uma cópia backup deste código

for file_cont=1:total_files
    [file_path,file_name,ext] = fileparts([dir_path '\' all_files{file_cont}]);
    tf = strcmp(extension,ext) %compara extensões
    
    if tf==1
        
        diretorio_arquivo=[pwd '\arquivos\' date_noww '\' file_name]; %Diretorio do arquivo lido
        mkdir([diretorio_arquivo]); %Cria diretório
        
        
        DATA_FULL=convertTDMS(0,[file_path '\' file_name ext]); %convert tdms to workspace matlab
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
        
        % Redução de amostragem 1 ponto por segundo, vetor tempo em horas
        Tempo_torque=downsample(Tempo_torque_orig',DATA_aqs_rate(6))*3600;
        torque=downsample(torque_orig',DATA_aqs_rate(6));
        torque=torque';
        carga=downsample(carga_orig',DATA_aqs_rate(5));
        carga=carga';
        temperaturas(:,1)=downsample(temperaturas_orig(:,1)',DATA_aqs_rate(4));
        temperaturas(:,2)=downsample(temperaturas_orig(:,2)',DATA_aqs_rate(4));
        temperaturas(:,3)=downsample(temperaturas_orig(:,3)',DATA_aqs_rate(4));
        temperaturas(:,4)=downsample(temperaturas_orig(:,4)',DATA_aqs_rate(4));
        
        [temperatura_cor(:,1),temperatura_cor(:,2),temperatura_cor(:,3),temperatura_cor(:,4)]=ajuste_temperatura(temperaturas(1:length(Tempo_torque),1),temperaturas(1:length(Tempo_torque),2),temperaturas(1:length(Tempo_torque),3),temperaturas(1:length(Tempo_torque),4));
        
        
        %     %dia
        %     DATA_Date{1}
        %     %torque rp
        %     [media_30s_torque]=media_30s(Tempo_torque,torque/4)
        %     %T1
        %     temperatura_inicial=temperatura1_cor(1)
        %     %Tend-t1
        %     [media_30s_temperaturas]=media_30s(Tempo_torque,temperatura1_cor);
        %     delta_temperatura=media_30s_temperaturas-temperatura1_cor(1)
        
        
        
        %% 3. Plot
        
        %% Torque vs temperatura
        figure
        set(gcf,'Name',['1 - Torque vs Temperatura'],'NumberTitle','off');
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
        title('Torque x Temperatura','FontSize',20) %Legend options
        
        yyaxis left
        hold on
        plot(Tempo_torque,torque,'red','LineWidth',3); %Blindagem
        hold on
        % legend('Célula de Torque','Torque viscoso médio','Torque viscoso malha')
        % legend('Célula de Torque','Modelo proposto','Modelo proposto carga 2x','Modelo proposto carga 3x','Houpert','SKF','','FontSize',20)
        ylabel('Torque (N.m)','FontSize',20)
        xlabel('Tempo (segundos)','FontSize',20)
        %     ylim([0 1])
        %     xlim([0 8])
        hold on
        
        yyaxis right
        plot(Tempo_torque,temperatura_cor(1:length(Tempo_torque),1),'color',[0.4660 0.6740 0.1880],'LineWidth',3); %Referencia
        ylabel('Temperatura (°C)','FontSize',20,'color',[0.4660 0.6740 0.1880])
        hold on
        grid minor
        % legend('Célula de Torque','Modelo proposto','Modelo proposto carga 2x','Houpert','SKF','FontSize',20)
        legend('Torque medido','Temperatura medida','FontSize',20)
        hold on
        saveas(gcf, [diretorio_arquivo '\1 - TorquevsTemperatura.jpg']);
        saveas(gcf, [diretorio_arquivo '\1 - TorquevsTemperatura.fig']);
        
        %%
        figure %Abre uma nova janela para plotar gráfico no MATLAB
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
        set(gcf,'Name',['2 - Temperaturas'],'NumberTitle','off');
        hold on
        plot(Tempo_torque,temperatura_cor(1:length(Tempo_torque),1),'red','LineWidth',3); %Blindagem
        hold on
        plot(Tempo_torque,temperatura_cor(1:length(Tempo_torque),2),'magenta','LineWidth',3); %face da base rigida
        hold on
        plot(Tempo_torque,temperatura_cor(1:length(Tempo_torque),3),'yellow','LineWidth',3); %topo da base rigida
        hold on
        plot(Tempo_torque,temperatura_cor(1:length(Tempo_torque),4),'blue','LineWidth',3); %Temperatura ambiente
        hold on
        title('Evolução de temperaturas ao longo do ensaio','FontSize',20) %Nome no gráfico
        xlabel('Tempo (segundos)') %Texto no eixo X
        ylabel('Temperatura (ºC)') %Texto no eixo Y
        legend('Rolamento','Face da Base Rígida','Topo da Base Rígida','Temperatura ambiente')
        % xlim([0 8]) %Limites gráficos no eixo X
        % ylim([0 40]) %Limites gráficos no eixo Y
        grid on %Linhas de grade no gráfico
        saveas(gcf, [diretorio_arquivo '\2_temperaturas.jpg']); %Salva a janela de plot no diretório do código
        saveas(gcf, [diretorio_arquivo '\2_temperaturas.fig']); %Salva a janela de plot no diretório do código
        
        
        % Carga no tempo
        figure
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
        set(gcf,'Name',['3 - Carga'],'NumberTitle','off');
        xlabel('Tempo (segundos)')
        ylabel('Carga (kN)')
        title('Carga ao longo do ensaio','FontSize',20) %Legend options
        hold on
        plot(Tempo_torque,carga,'red'); %Blindagem
        grid on
%         ylim([0 3])
        grid on
        saveas(gcf, [diretorio_arquivo '\3 - Carga.jpg']);
        saveas(gcf, [diretorio_arquivo '\3 - Carga.fig']);
        
        
        % Carga na frequência
        Fs_carga=DATA_aqs_rate(5); %amostras por segundo
        [FFT_carga,f_carga]=Fast_fourier(carga_orig,length(carga_orig),Fs_carga);
        figure
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
        set(gcf,'Name',['4 - FFT_Carga*60'],'NumberTitle','off');
        xlabel('Frequência*60 (Hz*60)')
        ylabel('Carga (kN)')
        title('Frequência de rotação pela célula de carga','FontSize',20) %Legend options
        hold on
        plot(f_carga(3:end)*60,FFT_carga(3:end),'blue','LineWidth',2)
        
        [~,max_position]=max(FFT_carga(3:end));
        RPM_fromFFT=f_carga(3+max_position)*60;
        RPM_fromFFT=round(RPM_fromFFT);
        
        grid minor
        xlim([800 3100])
        saveas(gcf, [diretorio_arquivo '\4 - FFT.jpg']);
        saveas(gcf, [diretorio_arquivo '\4 - FFT.fig']);
        
        
        %% 4. Exportar dados para .csv
        
        salvar_dados(:,1)=Tempo_torque(1:length(Tempo_torque));
        salvar_dados(:,2)=torque(1:length(Tempo_torque));
        salvar_dados(:,3)=carga(1:length(Tempo_torque));
        salvar_dados(:,4)=temperatura_cor(:,1);
        salvar_dados(:,5)=temperatura_cor(:,2);
        salvar_dados(:,6)=temperatura_cor(:,3);
        salvar_dados(:,7)=temperatura_cor(:,4);
        
        csvwrite([diretorio_raiz '\' file_name '.txt'],salvar_dados)
        
        
        
        %dados necessarios para preencher tabela
        salvar_dados2{:,1}=DATA_Date{1};
        salvar_dados2{:,2}=media_30min(Tempo_torque,torque/4);
        salvar_dados2{:,3}=temperatura_cor(1,1);
        salvar_dados2{:,4}=media_30min(Tempo_torque,temperatura_cor(:,1));
        salvar_dados2{:,5}=salvar_dados2{:,4}-salvar_dados2{:,3};
        salvar_dados2{:,6}=RPM_fromFFT;
        
        
        % Convert cell to a table and use first row as variable names
        T = cell2table(salvar_dados2,'VariableNames',{'Data' 'TorqueRP' 'T_inicial' 'T_RP' 'T_Delta' 'RPM_check'});
        
        % Write the table to a CSV file
        writetable(T,[diretorio_raiz '\' file_name '_tabela.csv'])
        
        %% Clear all created data to renew
        clear DATA_FULL DATA_Date DATA_Names DATA_Values DATA_Units DATA_aqs_rate
        clear temperaturas_orig Tempo_temperatura carga_orig  Tempo_carga torque_orig Tempo_torque_orig temperaturas
        clear salvar_dados salvar_dados2 T
        
        clear Tempo_torque torque carga temperaturas temperatura_cor
        clear FFT_carga f_carga
        clear RPM_fromFFT max_position
    end
    pause 
    close all force
end
tempo_cdg=toc/60;%Tempo para rodar o codigo
warndlg(sprintf(['Tudo pronto, Tempo de execução: ' num2str(tempo_cdg,2) ' min']));
winopen(diretorio_raiz);

%% 4 - Subrotinas

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
media_30min_torque1=soma_torque/cont_torque
media_30min_torque=mean(torque_exp(end-cont_torque:end))
desvio_30min_torque=std(torque_exp(end-cont_torque:end))
end


% 17 - Valor médio de uma propriedade nos últimos 30sutos de ensaio
function [media_30s_torque]=media_30s(tempo_exp,torque_exp)
% cálculo da média de torque nos ultimos 30s de ensaio
tempo_em_horas=1/120;
tempo_30s_torque=tempo_exp(end)-tempo_em_horas; %

% varedura
soma_torque=0;
cont_torque=0;
for i=1:length(tempo_exp)
    if tempo_exp(i)>=tempo_30s_torque
        soma_torque=soma_torque+torque_exp(i);
        cont_torque=cont_torque+1;
    end
end
media_30s_torque1=soma_torque/cont_torque;
media_30s_torque=mean(torque_exp(end-cont_torque:end));
desvio_30s_torque=std(torque_exp(end-cont_torque:end));
end

% FFT
function [P1,f]=Fast_fourier(S,L,Fs)
Y = fft(S);
P2 = abs(Y/(L));
P1 = P2(1:L/2+1);
P1(2:end-1) = P1(2:end-1);
f = Fs*(0:(L/2))/L;
end