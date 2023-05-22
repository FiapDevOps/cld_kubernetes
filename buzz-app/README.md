# cicd-buzz

This is a python buzzwords generator based at paper ["How to build a modern CI/CD pipeline"](https://medium.com/bettercode/how-to-build-a-modern-ci-cd-pipeline-5faa01891a5b) publicated at [Medium](https://medium.com) by [Rob van der Leek](https://medium.com/@robvanderleek?source=post_header_lockup);

This repo have the following content:

```sh
.
├── buzz
│   ├── generator.py         # The buzz words generator
│   └── __init__.py
├── requirements.txt         # Requeriments files, You know... to install stuffs
└── tests
    └── test_generator.py    # Sample test using pytest
```

Build Instructions:

```sh
docker build . -t buzz-app
```

So now you can make a quickl test:

```sh
docker run -d -p 80:5000 buzz-app
curl 127.0.0.1
```

---

**References:**

* ["How to build a modern CI/CD pipeline"](https://medium.com/bettercode/how-to-build-a-modern-ci-cd-pipeline-5faa01891a5b) by [Rob van der Leek](https://medium.com/@robvanderleek?source=post_header_lockup);

---

##### Fiap - MBA
profhelder.pereira@fiap.com.br

**Free Software, Hell Yeah!**