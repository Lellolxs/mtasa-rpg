txd = engineLoadTXD ("flatbed.txd")
engineImportTXD (txd, 578)

dff = engineLoadDFF ("flatbed.dff")
engineReplaceModel (dff, 578)