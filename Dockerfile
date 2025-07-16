FROM python:3.10-slim

# Copier le binaire dans le conteneur
COPY dist/add2vals /usr/local/bin/add2vals

# Rendre exécutable
RUN chmod +x /usr/local/bin/add2vals

# Point d'entrée par défaut
ENTRYPOINT ["add2vals"]
