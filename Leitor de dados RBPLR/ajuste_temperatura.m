%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Doutorado em Engenharia Mecânica PPGEM
%Federal University of Technology - Paraná (UTFPR) - Campus Curitiba
%Laboratório de Análise de Superfície de Contato - LASC
%Aluno: Marcos Takahama
%Professor: Tiago Cousseau , Cezar Otaviano Ribeiro Negrão
%% Subrotina para correção dos termopares tipo K da bancada RBPLR
% fev 2023
% Ajuste linear

function [T1cor,T2cor,T3cor,T4cor]=ajuste_temperatura(T1,T2,T3,T4)
%% 1-  Dados experimentais obtidos por banho térmico
T_banhotermico=[10:10:60]; %medidas de referências de 10 a 60 (10 em 10) graus celsius

%Termopar 1

termopar_min(:,1)=[10.02 19.59 29.28 39 48.71 58.43];
termopar_max(:,1)=[10.06 19.62 29.32 39.02 48.75 58.47];
termopar(:,1)=(termopar_min(:,1)+termopar_max(:,1))/2; % Valores médios usados para ajuste

%Termopar 2

termopar_min(:,2)=[10 19.61 29.31 39.05 48.75 58.47];
termopar_max(:,2)=[10.03 19.63 29.36 39.08 48.77 58.54];
termopar(:,2)=(termopar_min(:,2)+termopar_max(:,2))/2; % Valores médios usados para ajuste

%Termopar 3

termopar_min(:,3)=[9.74 19.57 29.46 39.38 49.21 59.07];
termopar_max(:,3)=[9.77 19.61 29.49 39.42 49.24 59.09];
termopar(:,3)=(termopar_min(:,3)+termopar_max(:,3))/2; % Valores médios usados para ajuste

%Termopar 4

termopar_min(:,4)=[9.78 19.64 29.53 39.47 49.3 59.15];
termopar_max(:,4)=[9.83 19.68 29.58 39.49 49.32 59.19];
termopar(:,4)=(termopar_min(:,4)+termopar_max(:,4))/2; % Valores médios usados para ajuste


% Mínimos quadrados e coeficientes lineares
p(1,:)=polyfit(T_banhotermico',termopar(:,1),1);
p(2,:)=polyfit(T_banhotermico',termopar(:,2),1);
p(3,:)=polyfit(T_banhotermico',termopar(:,3),1);
p(4,:)=polyfit(T_banhotermico',termopar(:,4),1);

%ax+b=y, onde p(1)=a, onde p(2)=b;
T_minimosquadrados=linspace(10,60,1000);

[m,n]=size(termopar);

%% 2 - Teste de ajuste de temperaturas nas próprias temperaturas medidas
for j=1:n
    for i=1:length(T_minimosquadrados)
        y(i,j)=p(j,1)*T_minimosquadrados(i)+p(j,2);
    end
end

for i=1:n
    diferenca(:,i)=T_banhotermico'-termopar(:,i);
    desvio_padrao(:,i)=std(termopar(:,i));
end

for j=1:n
    for i=1:length(termopar(:,1))
        T_correcao(i,j)=(termopar(i,j)-p(j,2))/p(j,1);
    end
end
% 
% % plot data
% figure
% set(gcf,'Name',['1 - plot temperaturas registradas'],'NumberTitle','off');
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
% plot(T_banhotermico,T_banhotermico,'kx'); %Temperatura do banho térmico
% hold on
% plot(T_banhotermico,termopar(:,1),'ro'); %Pontos do termopar 1
% hold on
% plot(T_minimosquadrados,y(:,1),'r'); %Reta mínimos quadrados
% hold on
% plot(T_banhotermico,T_correcao(:,1),'rd'); %Correção calculada do termopar 1
% hold on
% plot(T_banhotermico,termopar(:,2),'bo'); %Pontos do termopar 2
% hold on
% plot(T_minimosquadrados,y(:,2),'b'); %Reta mínimos quadrados
% hold on
% plot(T_banhotermico,T_correcao(:,2),'bd'); %Correção calculada do termopar 2
% hold on
% plot(T_banhotermico,termopar(:,3),'mo'); %Pontos do termopar 3
% hold on
% plot(T_minimosquadrados,y(:,3),'m'); %Reta mínimos quadrados
% hold on
% plot(T_banhotermico,T_correcao(:,3),'md'); %Correção calculada do termopar 3
% hold on
% plot(T_banhotermico,termopar(:,4),'go'); %Pontos do termopar 4
% hold on
% plot(T_minimosquadrados,y(:,4),'g'); %Reta mínimos quadrados
% hold on
% plot(T_banhotermico,T_correcao(:,4),'gd'); %Correção calculada do termopar 4
% grid on
% title('Desvio Termopares','FontSize',20) %Legend options
% xlabel('Banho térmico (ºC)')
% ylabel('Temperatura registrada(ºC)')
% legend('real','Termopar 1','MQ 1','Correção Termopar 1','Termopar 2','MQ 2','Correção Termopar 2','Termopar 3','Correção Termopar 3','MQ 3','Termopar 4','MQ 4','Correção Termopar 4')
% saveas(gcf, [diretorio_cdg '\1_Correcao_termopar.jpg']);


%% 3 - Correção das tem

% temperaturas(:,1:4)=[DATA_Values{:,1:4}]; %Temperaturas dos termopares que vão ser corrigidos
temperaturas(:,1)=T1; %Temperaturas dos termopares que vão ser corrigidos
temperaturas(:,2)=T2; %Temperaturas dos termopares que vão ser corrigidos
temperaturas(:,3)=T3; %Temperaturas dos termopares que vão ser corrigidos
temperaturas(:,4)=T4; %Temperaturas dos termopares que vão ser corrigidos
temperaturas_original=temperaturas; %Temperaturas dos termopares inalterados

cont=0;
for j=1:4
    for i=1:length(temperaturas(:,j))
        temperaturas_corrigidas(i,j)=(temperaturas(i,j)-p(j,2))/p(j,1);
        cont=cont+1;
    end
end

T1cor=temperaturas_corrigidas(:,1); 
T2cor=temperaturas_corrigidas(:,2); 
T3cor=temperaturas_corrigidas(:,3); 
T4cor=temperaturas_corrigidas(:,4); 
end

