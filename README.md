
<h2> Tool for whole font modifications with reaction-diffusion algorithm</h2>

Garder l'arborescence tel quel pour lancer fontBuilder.pde avec processing 2.xx 

<pre>
  fontBuilder/fontBuilder.pde
  fontBuilder/data/
  fontBuilder/code/
</pre>

mettre la fonte à modifier dans data/ et la renommer "fontSource.ttf".
<br/>
Par défaut la fonte crée apparaitra dans data/output/bin/

<pre>
KEYBOARD INTERFACE DOCUMENTATION
sliders :    
  + - 
  A Q  TIME  - temps d'action de l'algorithme
  Z S  SEUIL - valeur de gris, seuil de la vectorisation
  E D  SIZE  - taille de la pixellisation des lettres
  R F  BLUR  - lisse la vectorisation
  T G  RESOL - réduit les point de vecteurs
 
  U J  PARAM 4 |
  I K  PARAM 3 | Paramètres
  O L  PARAM 2 | de l'algorithme
  P M  PARAM 1 |

active/desactive :
  W   - la prévisualisation de la vectorisation
  X   - l'inversion des valeurs de gris des pixels
  C
  V
  B
  N
 CTRL - l'édition du text de prévisualisation au clavier
SPACE - exporte la fonte TTF
</pre><
