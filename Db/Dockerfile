# Use the official Microsoft SQL Server image
FROM mcr.microsoft.com/mssql/server:2022-latest

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . /usr/src/app

# Grant permissions for the scripts to be executable
USER root
RUN chmod +x /usr/src/app/*.sh
USER mssql

# Specify the command to run on container startup
CMD exec /bin/bash -c "/usr/src/app/run-initialization.sh & /opt/mssql/bin/sqlservr"