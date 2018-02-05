clear all;

%%Données initiales
PV = [30,27,26,30,35,20];
CHM = [1,3,1,3,2,3,1];
TU = [8,7,8,2,15,5,13
    5,2,1,10,0,5,3
    0,12,11,5,8,3,5
    5,5,0,4,7,12,8
    0,7,10,13,10,8,10
    5,8,0,7,0,6,7];
QMP = [1,2,1,1,2,1
    3,2,1,1,1,2
    0,1,1,3,2,0];
CMP = [2,4,1];


MAXPROD = 622.451;
MAXBENEF = 10000.5;

%% Contraintes
temps_2_8 = 60*2*8*5;

produits = [1 2 1 1 2 1 ;
            3 2 1 1 1 2 ;
            0 1 1 3 2 0 ];
maxMP = [850 920 585];
        
tempsMachines = [ 8 5 0 5 0 5 ;
                7 2 12 5 7 8 ;
                8 1 11 0 10 0 ;
                2 10 5 4 13 7 ;
                15 0 8 7 10 0 ;
                5 5 3 12 8 6 ;
                13 3 5 8 10 7 ];
maxTemps = ones(1,7) * temps_2_8;
minPrix = zeros(1,6);



A = [produits ;
   tempsMachines;
    - eye(6);
    ];
B = [maxMP maxTemps minPrix];


% À COMMENTER SI DIFFÉRENT DE ZQUATRE
Aeq = [1 1 1 -1 -1 -1];

Beq = [0];
% FIN COMMENTAIRE

%% Couts

%Comptable
CTM = (CHM/60)*TU';
CTMP = CMP*QMP;
ZUn = (PV - CTM - CTMP);

%Responsable d'atelier

ZDeux = ones(1,6);

%Responsable des stocks
%%% Tracé stock en fct de activité version qté
Emplacement_Produits = [5,6,4,6,6,4];

C= [produits ;
   tempsMachines;
    - eye(6);
    -ZDeux;
    ];

X=0:0.01:0.999;
ZTOT=zeros(1,length(X));
tmp = zeros(6,1);
for i=X
D = [maxMP maxTemps minPrix -i*MAXPROD];
Z3 = linprog(Emplacement_Produits,C,D);
tmp = [tmp Z3];
ZTOT(round(i*100+1))=Emplacement_Produits*Z3;
end

hold on
figure(1)
title('Stocks en fonction de la quantité de production');
plot(X,ZTOT);
plot(X, X * (ZTOT(end)/X(end)))
hold off
legend('ZTOT','linéaire');

%%% Tracé en fct benef

C= [produits ;
   tempsMachines;
    - eye(6);
    -ZUn;
    ];

ZTOT2=zeros(1,length(X));
tmp2 = zeros(6,1);
for i=X
D = [maxMP maxTemps minPrix -i*MAXBENEF];
Z32 = linprog(Emplacement_Produits,C,D);
tmp2 = [tmp2 Z32];
ZTOT2(round(i*100+1))=Emplacement_Produits*Z32;
end


figure(2)
title('Stocks en fonction de la quantité de production');
plot(X,ZTOT2);
hold on
plot(X, X * (ZTOT2(end)/X(end)))
hold off
legend('ZTOT2','linéaire2');

%Responsable Commercial

ZQuatre = ZUn;

% L'ami des machines

T1_3 = [16 6 11 5 10 5];
ZCinq = -ZUn./norm(ZUn) + T1_3./norm(T1_3);

% L'ami des machines - Welcome to the machine

pas = 200;
resultats=zeros(3,round(MAXBENEF/pas)+1);

for i=0:pas:MAXBENEF
    Aprime = [A ;
            -ZUn];    
    Bprime = [B -i];
    
    T1 = [8 5 0 5 0 5];
    T3 = [8 1 11 0 10 0];
    T1_3 = [16 6 11 5 10 5];
    %% Résolution
% %     T1
% %     temp=linprog(T1, Aprime, Bprime);
% %     T3
% %     temp=linprog(T3, Aprime, Bprime);
    %T1_3
    temp=linprog(T1_3, Aprime, Bprime);
    resultats(:, round(i/pas)+1)= [T1 * temp; T3 * temp; T1_3 * temp;];
end

plot(0:pas:MAXBENEF, resultats(1,:), '-r');
hold on;
plot(0:pas:MAXBENEF, resultats(2,:), '-b');
plot(0:pas:MAXBENEF, resultats(3,:), 'og');
xlabel('Revenus');
ylabel('Temps d''utilisation')
legend('M1','M3','M1 + M3','Location','northwest');



%% Résolution

Z = linprog(-ZUn, A, B)%, Aeq, Beq) %Décommenter pour Commercial

prod = ZUn * Z

