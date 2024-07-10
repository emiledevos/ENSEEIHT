import numpy as np
import random as rd
import matplotlib.pyplot as plt
import scipy.sparse as scps
import scipy.interpolate as interp

def maillage(n, min, max, bruit, f, ordre = 2) :
# creation d'un maillage
# entrees:
#   - n : nombre de quadrillage
#   - min : borne inferieure de l'intervalle
#   - max : borne superieure de l'intervalle
#   - bruit : amplitude du bruit
#   - f : fonction a approximer
#   - ordre : ordre de l'approximation
# sorties:
#   - coord : Matrice des coordonnees des points de contrôle
#   - triangle : Matrice des indices des points des triangles

    quad = n*ordre + 1
    # creation des points de controle
    coordtemp = np.zeros((quad**2, 2))
    coord = np.zeros((quad**2, 3))
    for i in range(quad):
        for j in range(quad):
            coordtemp[i*quad+j] = [min + (max-min)*i/(quad-1) + bruit*rd.random(), min + (max-min)*j/(quad-1)+ bruit*rd.random()]
            coord[i*quad+j] = [coordtemp[i*quad+j][0], coordtemp[i*quad+j][1], f(coordtemp[i*quad+j][0], coordtemp[i*quad+j][1])]
    
    # creation des triangles
    triangle  = np.zeros((2*(n**2), (ordre+1)*(ordre+2)//2), dtype=int)
    for i in range(n):
        for j in range(n):
            ind = 2*(i*n +j)
            l1 = []
            l2 = []
            for k in range(ordre+1):
                for l in range(ordre+1-k):
                    l1.append((i*ordre + k)*quad + j*ordre + l)
            for k in range(ordre, -1, -1):
                for l in range(ordre-k, ordre+1):
                    l2.append((i*ordre + k)*quad + j*ordre + l)
            triangle[ind] = l1
            triangle[ind+1] = l2
    return coord, triangle

def affichage_maillage(coord, triangle, fig, ordre = 2):
# affichage d'un maillage
# entrees:
#   - coord : Matrice des coordonnees des points de contrôle
#   - triangle : Matrice des indices des points des triangles
#   - fig : figure sur laquelle afficher le maillage
#   - ordre : ordre de l'approximation
    for t in triangle:
        for i in range(ordre):
            for j in range(ordre-i):
                ind = (ordre+1)*(ordre+2)//2-(ordre+1-i)*(ordre+2-i)//2+j
                if i == 0:
                    fig.plot([coord[t[ind], 0], coord[t[ind+1],0]], [coord[t[ind],1], coord[t[ind+1],1]],[coord[t[ind],2], coord[t[ind+1],2]], 'r')
                else : 
                    fig.plot([coord[t[ind], 0], coord[t[ind+1],0]], [coord[t[ind],1], coord[t[ind+1],1]],[coord[t[ind],2], coord[t[ind+1],2]], 'b')
                if j == 0:
                    fig.plot([coord[t[ind], 0], coord[t[ind + ordre +1 - i],0]], [coord[t[ind],1], coord[t[ind + ordre + 1 - i],1]],[coord[t[ind],2], coord[t[ind + ordre + 1 - i],2]], 'r')
                else:
                    fig.plot([coord[t[ind], 0], coord[t[ind + ordre +1 - i],0]], [coord[t[ind],1], coord[t[ind + ordre + 1 - i],1]],[coord[t[ind],2], coord[t[ind + ordre + 1 - i],2]], 'b')
                if i+j == ordre-1 :
                    fig.plot([coord[t[ind + ordre + 1 - i], 0], coord[t[ind+1],0]], [coord[t[ind + ordre + 1 - i],1], coord[t[ind+1],1]],[coord[t[ind + ordre + 1 - i],2], coord[t[ind+1],2]], 'r')
                else : 
                    fig.plot([coord[t[ind + ordre + 1 - i], 0], coord[t[ind+1],0]], [coord[t[ind + ordre + 1 - i],1], coord[t[ind+1],1]],[coord[t[ind + ordre + 1 - i],2], coord[t[ind+1],2]], 'b')



def Decasteljau(coord, triangle, ordre, u,v) :
# Algorithme de De Casteljau
# entrees:
#   - coord : Matrice des coordonnees des points de contrôle
#   - triangle : Matrice des indices des points des triangles
#   - ordre : ordre de l'approximation
#   - u,v : coordonnees du point ou evaluer la fonction
# sorties:
#   - p : valeur de l'apprixmation en u,v
    if ordre == 1 : 
        p1 = coord[triangle[0]]
        p2 = coord[triangle[1]]
        p3 = coord[triangle[2]]
    else :
        l=[[]]*(ordre+1)
        for i in range(ordre+1):
            ind = (ordre+1)*(ordre+2)//2-(ordre+1-i)*(ordre+2-i)//2
            l[i] = list(triangle[ind : ind + ordre + 1 - i])
        t1, t2, t3 = [], [], []
        for i in range(ordre):
            t1 += l[i][:-1]
            t2 += l[i][1:]
            t3 += l[i+1]
        p1 = Decasteljau(coord, t1, ordre-1, u, v)
        p2 = Decasteljau(coord, t2, ordre-1, u, v)
        p3 = Decasteljau(coord, t3, ordre-1, u, v)
    return u*p1 + v*p2 + (1-u-v)*p3

def approx_bezier(coord, Triangle, nb_exchantillon, ordre):
# approximation de la fonction par morceaux par une fonction de Bézier
# en entrée :
#       - coord : coordonnées des points du maillage
#       - triangle : connectivité des triangles
#       - nb_echantillon : nombre de points de l'échantillon
# en sortie :
#       - coord_bezier : matrice de taille nx3 des coordonnées des points de l'échantillon

    coord_bezier = np.zeros((int((nb_exchantillon/2)*(1+nb_exchantillon)*len(Triangle)),3))
    ind = 0
    for k in range(len(Triangle)):
        triangle = Triangle[k]
        for i in range(nb_exchantillon):
            for j in range(nb_exchantillon-i):
                u = i/(nb_exchantillon-1)
                v = j/(nb_exchantillon-1) 
                coord_bezier[ind] = Decasteljau(coord, triangle, ordre, u,v)
                ind += 1
    return coord_bezier

def show(coord, triangle, coord_bezier, ordre):
# affichage des points de contrôle, du maillage et de l'approximation par morceaux de Bézier
# en entrée :
#       - coord : coordonnées des points du maillage
#       - triangle : connectivité des triangles
#       - coord_bezier : coordonnées des points de l'échantillon
#       - ordre : ordre de l'approximation
    
    #affichage des points de contrôle
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    ax.scatter(coord[:,0],coord[:,1],coord[:,2])
    for i in range(len(coord)):
        ax.text(coord[i,0],coord[i,1],coord[i,2],  '%s' % (str(i)), size=20, zorder=1, color='k')
    ax.set_title('Points de contrôle')
    plt.show()

    #affichage du maillage et des points de contrôle
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    ax.scatter(coord[:,0],coord[:,1],coord[:,2])
    affichage_maillage(coord, triangle, ax, ordre)
    ax.set_title('Maillage des triangles de Bézier')
    plt.show()

    #affichage de l'approximation par morceaux de Bézier avec le maillage
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    affichage_maillage(coord, triangle, ax, ordre)
    ax.scatter(coord_bezier[:,0],coord_bezier[:,1],coord_bezier[:,2])
    ax.set_title('Approximation par morceaux de Bézier')
    plt.show()

    #affichage de la surface approximante par patch et les points de l'échantillon
    # affichage des surfaces des patchs de Bézier et les points de l'échantillon
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    ax.scatter(coord_bezier[:,0],coord_bezier[:,1],coord_bezier[:,2])
    nb_coord = int(len(coord_bezier)/len(triangle))
    #création des surfaces des patchs de Bézier
    for i in range(len(triangle)):    
        plotx, ploty = np.meshgrid(np.linspace(np.min(coord_bezier[i*nb_coord:(i+1)*nb_coord,0]), np.max(coord_bezier[i*nb_coord:(i+1)*nb_coord,0]),nb_coord), np.linspace(np.min(coord_bezier[i*nb_coord:(i+1)*nb_coord,1]),np.max(coord_bezier[i*nb_coord:(i+1)*nb_coord,1]),nb_coord))
        plotz = interp.griddata((coord_bezier[i*nb_coord:(i+1)*nb_coord,0],coord_bezier[i*nb_coord:(i+1)*nb_coord,1]),coord_bezier[i*nb_coord:(i+1)*nb_coord,2],(plotx,ploty),method='linear')
        ax.plot_surface(plotx,ploty,plotz, color='g', alpha=0.5)
    ax.set_title('Surface approximante par patch')
    plt.show()


if __name__ == '__main__':
    #f = lambda x,y : x**2 + y**2
    f = lambda x,y : np.sin(np.sqrt(x**2 + y**2))
    #f = lambda x,y : np.exp(-x + y)
    #f = lambda x,y :np.sqrt(64 - x**2 - y**2)
    ordre = 4
    nb_exchantillon = 10
    nb_maillage = 2
    min, max = 0, 5
    bruit = 0.1

    coord, triangle = maillage(nb_maillage, min, max, bruit, f, ordre)
    coord_bezier = approx_bezier(coord, triangle, nb_exchantillon, ordre)
    show(coord, triangle,coord_bezier,  ordre)