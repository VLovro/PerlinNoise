import random
import numpy as np
import matplotlib.pyplot as plt
import time

def permutacijska_tablica():
    permutacija = list(range(256))
    permutacija += permutacija
    return permutacija


def fade(t):
    return t * t * t


def lerp(a, b, x):
    return (1 - x) * a + x * b


def gradijent(indeks, x, y):
    vektori = np.array([0, np.pi/2, np.pi, 3*np.pi/2])
    x_komponenta = np.cos(vektori[indeks % 4])
    y_komponenta = np.sin(vektori[indeks % 4])
    return x_komponenta*x + y_komponenta*y


def noiseFunkcija(x, y, frek, ampl):
        
    x1 = np.floor(x*frek).astype(int) 
    y1 = np.floor(y*frek).astype(int)
    x2 = x * frek - x1
    y2 = y * frek - y1
    xfade = fade(x2)
    yfade = fade(y2)
    
    p = permutacijska_tablica()
    perm_tablica = np.array(p, dtype=int) 

    a = gradijent(perm_tablica[perm_tablica[x1] + y1], x2, y2)
    b = gradijent(perm_tablica[perm_tablica[x1] + y1 + 1], x2, y2 - 1)
    b1 = gradijent(perm_tablica[perm_tablica[x1 + 1] + y1 + 1], x2 - 1, y2 - 1)
    a1 = gradijent(perm_tablica[perm_tablica[x1 + 1] + y1], x2 - 1, y2)

    x3 = lerp(a, a1, xfade)
    x4 = lerp(b, b1, xfade)
    return lerp(x3, x4, yfade) * ampl

def perlin_oktave(x, y, oktave, persistence):
    rezultat = 0
    frekvencija = 0.2
    amplituda = 1
    max_vrij = 0

    for i in range(oktave):
        rezultat += noiseFunkcija(x, y, frekvencija, amplituda) * amplituda
        max_vrij += amplituda
        amplituda *= persistence
        frekvencija *= 2

    return rezultat / max_vrij


mapa_visina = np.zeros((100, 100))
for i in range(100):
    for j in range(100):
        mapa_visina[i, j] = np.sin(i/20.0) + np.cos(j/10.0)


pocetak = time.time()
x, y = np.meshgrid(np.linspace(0, 20, 100), np.linspace(0, 20, 100))
noise = perlin_oktave(x, y, oktave=6, persistence=0.5)

noise1 = noise * mapa_visina
fig = plt.figure()
plt.imshow(noise1, cmap='Reds', aspect=1.0)
kraj_izvodenja = time.time()

vrijeme_izvodenja = kraj_izvodenja - pocetak
print("Vrijeme: {:.2f} sekundi".format(vrijeme_izvodenja))
plt.axis('off')

plt.show()


