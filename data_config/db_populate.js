const firebase = require("firebase");
// Required for side-effects
require("firebase/firestore");

// Initialize Cloud Firestore through Firebase
firebase.initializeApp({
    apiKey: "AIzaSyBiJMtnRL8SZyoQGpZBYn49W4kTSAcA_BM",
    authDomain: "mydiet-6ee55.firebaseapp.com",
    projectId: "mydiet-6ee55"
  });
  
var db = firebase.firestore();

var data = [{
    "path": "./StudioProjects/MyDiet/data",
    "name": "data",
    "children": [
        {
            "path": "StudioProjects\\MyDiet\\data\\Friday",
            "name": "Friday",
            "children": [
                {
                    "path": "StudioProjects\\MyDiet\\data\\Friday\\0_Colazione",
                    "name": "0_Colazione",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\0_Colazione\\Burro.csv",
                            "name": "Burro.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\0_Colazione\\Caffe.csv",
                            "name": "Caffe.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\0_Colazione\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\0_Colazione\\Latte.csv",
                            "name": "Latte.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\0_Colazione\\Marmellata.csv",
                            "name": "Marmellata.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\0_Colazione\\Pane.csv",
                            "name": "Pane.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Friday\\1_Pranzo",
                    "name": "1_Pranzo",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\1_Pranzo\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\1_Pranzo\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\1_Pranzo\\Pasta.csv",
                            "name": "Pasta.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\1_Pranzo\\Uova.csv",
                            "name": "Uova.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Friday\\2_Merenda",
                    "name": "2_Merenda",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\2_Merenda\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\2_Merenda\\Marmellata.csv",
                            "name": "Marmellata.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\2_Merenda\\Noci.csv",
                            "name": "Noci.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\2_Merenda\\Yogurt.csv",
                            "name": "Yogurt.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Friday\\3_Cena",
                    "name": "3_Cena",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\3_Cena\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\3_Cena\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\3_Cena\\Pane.csv",
                            "name": "Pane.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\3_Cena\\Pesce Fresco.csv",
                            "name": "Pesce Fresco.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Friday\\4_Arco_Della_Giornata",
                    "name": "4_Arco_Della_Giornata",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Friday\\4_Arco_Della_Giornata\\Olio.csv",
                            "name": "Olio.csv"
                        }
                    ]
                }
            ]
        },
        {
            "path": "StudioProjects\\MyDiet\\data\\Monday",
            "name": "Monday",
            "children": [
                {
                    "path": "StudioProjects\\MyDiet\\data\\Monday\\0_Colazione",
                    "name": "0_Colazione",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\0_Colazione\\Caffe.csv",
                            "name": "Caffe.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\0_Colazione\\Derivati_Dei_Cereali_Farciti.csv",
                            "name": "Derivati_Dei_Cereali_Farciti.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\0_Colazione\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\0_Colazione\\Latte.csv",
                            "name": "Latte.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Monday\\1_Pranzo",
                    "name": "1_Pranzo",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\1_Pranzo\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\1_Pranzo\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\1_Pranzo\\Legumi_Secchi.csv",
                            "name": "Legumi_Secchi.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\1_Pranzo\\Pane.csv",
                            "name": "Pane.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Monday\\2_Merenda",
                    "name": "2_Merenda",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\2_Merenda\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\2_Merenda\\Marmellata.csv",
                            "name": "Marmellata.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\2_Merenda\\Noci.csv",
                            "name": "Noci.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\2_Merenda\\Yogurt.csv",
                            "name": "Yogurt.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Monday\\3_Cena",
                    "name": "3_Cena",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\3_Cena\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\3_Cena\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\3_Cena\\Spuntino_Serale.csv",
                            "name": "Spuntino_Serale.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\3_Cena\\Uova.csv",
                            "name": "Uova.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Monday\\4_Arco_Della_Giornata",
                    "name": "4_Arco_Della_Giornata",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Monday\\4_Arco_Della_Giornata\\Olio.csv",
                            "name": "Olio.csv"
                        }
                    ]
                }
            ]
        },
        {
            "path": "StudioProjects\\MyDiet\\data\\Saturday",
            "name": "Saturday",
            "children": [
                {
                    "path": "StudioProjects\\MyDiet\\data\\Saturday\\0_Colazione",
                    "name": "0_Colazione",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Saturday\\0_Colazione\\Caffe.csv",
                            "name": "Caffe.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Saturday\\0_Colazione\\Condimenti_Pancakes.csv",
                            "name": "Condimenti_Pancakes.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Saturday\\0_Colazione\\Latte.csv",
                            "name": "Latte.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Saturday\\0_Colazione\\Pancakes.csv",
                            "name": "Pancakes.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Saturday\\1_Pranzo",
                    "name": "1_Pranzo",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Saturday\\1_Pranzo\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Saturday\\1_Pranzo\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Saturday\\1_Pranzo\\Tacos Vegetariani.csv",
                            "name": "Tacos Vegetariani.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Saturday\\2_Merenda",
                    "name": "2_Merenda",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Saturday\\2_Merenda\\Derivati_Dei_Cereali_Farciti.csv",
                            "name": "Derivati_Dei_Cereali_Farciti.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Saturday\\3_Cena",
                    "name": "3_Cena",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Saturday\\3_Cena\\Pasto Libero.csv",
                            "name": "Pasto Libero.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Saturday\\4_Arco_Della_Giornata",
                    "name": "4_Arco_Della_Giornata",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Saturday\\4_Arco_Della_Giornata\\Olio.csv",
                            "name": "Olio.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Saturday\\4_Arco_Della_Giornata\\Pane.csv",
                            "name": "Pane.csv"
                        }
                    ]
                }
            ]
        },
        {
            "path": "StudioProjects\\MyDiet\\data\\Sunday",
            "name": "Sunday",
            "children": [
                {
                    "path": "StudioProjects\\MyDiet\\data\\Sunday\\0_Colazione",
                    "name": "0_Colazione",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\0_Colazione\\Caffe.csv",
                            "name": "Caffe.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\0_Colazione\\Dolci_Da_Forno.csv",
                            "name": "Dolci_Da_Forno.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\0_Colazione\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\0_Colazione\\Latte.csv",
                            "name": "Latte.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Sunday\\1_Pranzo",
                    "name": "1_Pranzo",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\1_Pranzo\\Carne_Conservata.csv",
                            "name": "Carne_Conservata.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\1_Pranzo\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\1_Pranzo\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\1_Pranzo\\Pasta.csv",
                            "name": "Pasta.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Sunday\\2_Merenda",
                    "name": "2_Merenda",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\2_Merenda\\Gelato.csv",
                            "name": "Gelato.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Sunday\\3_Cena",
                    "name": "3_Cena",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\3_Cena\\Carne_Fresca.csv",
                            "name": "Carne_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\3_Cena\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\3_Cena\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\3_Cena\\Pane.csv",
                            "name": "Pane.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Sunday\\4_Arco_Della_Giornata",
                    "name": "4_Arco_Della_Giornata",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Sunday\\4_Arco_Della_Giornata\\Olio.csv",
                            "name": "Olio.csv"
                        }
                    ]
                }
            ]
        },
        {
            "path": "StudioProjects\\MyDiet\\data\\Thursday",
            "name": "Thursday",
            "children": [
                {
                    "path": "StudioProjects\\MyDiet\\data\\Thursday\\0_Colazione",
                    "name": "0_Colazione",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\0_Colazione\\Caffe.csv",
                            "name": "Caffe.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\0_Colazione\\Derivati_dei_Cereali.csv",
                            "name": "Derivati_dei_Cereali.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\0_Colazione\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\0_Colazione\\Latte.csv",
                            "name": "Latte.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\0_Colazione\\Noci.csv",
                            "name": "Noci.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Thursday\\1_Pranzo",
                    "name": "1_Pranzo",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\1_Pranzo\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\1_Pranzo\\Edamame.csv",
                            "name": "Edamame.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\1_Pranzo\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\1_Pranzo\\Pane.csv",
                            "name": "Pane.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\1_Pranzo\\Pesce_Conservato copy.csv",
                            "name": "Pesce_Conservato copy.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Thursday\\2_Merenda",
                    "name": "2_Merenda",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\2_Merenda\\Barretta_Kinder.csv",
                            "name": "Barretta_Kinder.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\2_Merenda\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\2_Merenda\\Pane.csv",
                            "name": "Pane.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Thursday\\3_Cena",
                    "name": "3_Cena",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\3_Cena\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\3_Cena\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\3_Cena\\Pane.csv",
                            "name": "Pane.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\3_Cena\\Pesce Fresco.csv",
                            "name": "Pesce Fresco.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Thursday\\4_Arco_Della_Giornata",
                    "name": "4_Arco_Della_Giornata",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Thursday\\4_Arco_Della_Giornata\\Olio.csv",
                            "name": "Olio.csv"
                        }
                    ]
                }
            ]
        },
        {
            "path": "StudioProjects\\MyDiet\\data\\Tuesday",
            "name": "Tuesday",
            "children": [
                {
                    "path": "StudioProjects\\MyDiet\\data\\Tuesday\\0_Colazione",
                    "name": "0_Colazione",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\0_Colazione\\Caffe.csv",
                            "name": "Caffe.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\0_Colazione\\Latte.csv",
                            "name": "Latte.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\0_Colazione\\Marmellata.csv",
                            "name": "Marmellata.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\0_Colazione\\Pane.csv",
                            "name": "Pane.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\0_Colazione\\Philadelphia.csv",
                            "name": "Philadelphia.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Tuesday\\1_Pranzo",
                    "name": "1_Pranzo",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\1_Pranzo\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\1_Pranzo\\Formaggi_E_Latticini.csv",
                            "name": "Formaggi_E_Latticini.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\1_Pranzo\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\1_Pranzo\\Pasta.csv",
                            "name": "Pasta.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Tuesday\\2_Merenda",
                    "name": "2_Merenda",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\2_Merenda\\Cioccolato.csv",
                            "name": "Cioccolato.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\2_Merenda\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\2_Merenda\\Pane.csv",
                            "name": "Pane.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Tuesday\\3_Cena",
                    "name": "3_Cena",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\3_Cena\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\3_Cena\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\3_Cena\\Pane.csv",
                            "name": "Pane.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\3_Cena\\Pesce Fresco.csv",
                            "name": "Pesce Fresco.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Tuesday\\4_Arco_Della_Giornata",
                    "name": "4_Arco_Della_Giornata",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Tuesday\\4_Arco_Della_Giornata\\Olio.csv",
                            "name": "Olio.csv"
                        }
                    ]
                }
            ]
        },
        {
            "path": "StudioProjects\\MyDiet\\data\\Wednesday",
            "name": "Wednesday",
            "children": [
                {
                    "path": "StudioProjects\\MyDiet\\data\\Wednesday\\0_Colazione",
                    "name": "0_Colazione",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\0_Colazione\\Caffe.csv",
                            "name": "Caffe.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\0_Colazione\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\0_Colazione\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\0_Colazione\\Latte.csv",
                            "name": "Latte.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\0_Colazione\\Pane.csv",
                            "name": "Pane.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Wednesday\\1_Pranzo",
                    "name": "1_Pranzo",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\1_Pranzo\\Cereali.csv",
                            "name": "Cereali.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\1_Pranzo\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\1_Pranzo\\Formaggi_E_Latticini.csv",
                            "name": "Formaggi_E_Latticini.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\1_Pranzo\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Wednesday\\2_Merenda",
                    "name": "2_Merenda",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\2_Merenda\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\2_Merenda\\Marmellata.csv",
                            "name": "Marmellata.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\2_Merenda\\Noci.csv",
                            "name": "Noci.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\2_Merenda\\Yogurt.csv",
                            "name": "Yogurt.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Wednesday\\3_Cena",
                    "name": "3_Cena",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\3_Cena\\Carne_Fresca.csv",
                            "name": "Carne_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\3_Cena\\Contorni.csv",
                            "name": "Contorni.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\3_Cena\\Frutta_Fresca.csv",
                            "name": "Frutta_Fresca.csv"
                        },
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\3_Cena\\Pane.csv",
                            "name": "Pane.csv"
                        }
                    ]
                },
                {
                    "path": "StudioProjects\\MyDiet\\data\\Wednesday\\4_Arco_Della_Giornata",
                    "name": "4_Arco_Della_Giornata",
                    "children": [
                        {
                            "path": "StudioProjects\\MyDiet\\data\\Wednesday\\4_Arco_Della_Giornata\\Olio.csv",
                            "name": "Olio.csv"
                        }
                    ]
                }
            ]
        }
    ]
}]

data.forEach(function(obj) {
    db.collection("menu").add({
        id: obj.id,
        name: obj.name,
        description: obj.description,
        price: obj.price,
        type: obj.type
    }).then(function(docRef) {
        console.log("Document written with ID: ", docRef.id);
    })
    .catch(function(error) {
        console.error("Error adding document: ", error);
    });
});