# 📱 Reposición SIMCARD Corporativo

**Reposición SIMCARD Corporativo** es una aplicación web desarrollada para gestionar el proceso de reposición de tarjetas SIM en entornos corporativos. Está construida utilizando **ASP.NET (VB.NET)**, **JavaScript** y **HTML**, y se integra con bases de datos SQL para el manejo eficiente de la información.

## 🧩 Características Principales

- **Gestión de Reposiciones**: Permite registrar y seguir el estado de las solicitudes de reposición de SIM cards.
- **Interfaz Web Intuitiva**: Diseñada para facilitar el uso por parte del personal encargado de la gestión de SIMs.
- **Integración con Bases de Datos**: Utiliza procedimientos almacenados en SQL para operaciones eficientes y seguras.
- **Módulos Funcionales**:
  - `ingreso.aspx`: Registro de nuevas solicitudes de reposición.
  - `consulta.aspx`: Consulta y seguimiento de solicitudes existentes.
  - `detalle.aspx`: Visualización detallada de cada solicitud.
  - `reposicion_linea.aspx`: Gestión específica de la reposición de líneas.

## 🛠️ Tecnologías Utilizadas

- **Frontend**:
  - HTML
  - CSS
  - JavaScript

- **Backend**:
  - ASP.NET con VB.NET

- **Base de Datos**:
  - SQL Server con procedimientos almacenados (PLSQL y TSQL)

- **Otros**:
  - Scripts Shell para tareas automatizadas
  - Archivos CSV para importación/exportación de datos

## 📂 Estructura del Proyecto

- `/DOCS`: Documentación del proyecto.
- `/EJEMPLO`: Ejemplos y casos de uso.
- `/IMAGENES`: Recursos gráficos utilizados en la aplicación.
- `/SHELL`: Scripts de automatización.
- `/TABLA SQL`: Scripts de creación y manejo de la base de datos.
- `*.aspx`: Páginas web de la aplicación.
- `Conexion.txt`: Información de conexión a la base de datos.
- `objetos.zip`: Archivos adicionales relacionados con el proyecto.

## 🚀 Instalación y Configuración

1. **Clonar el Repositorio**:

   ```bash
   git clone https://github.com/Kimura-IV/Reposicion_SIMCARD_Corporativo.git

2. Configurar la Base de Datos:

- Crear la base de datos en SQL Server utilizando los scripts disponibles en /TABLA SQL.

- Asegurarse de que los procedimientos almacenados estén correctamente implementados.

3. Actualizar la Cadena de Conexión:

- Modificar el archivo Conexion.txt con los parámetros adecuados para tu entorno.

4. Desplegar la Aplicación:

- Abrir el proyecto en Visual Studio.

- Compilar y ejecutar la aplicación.

## 📌 Requisitos

- Software:

> Visual Studio con soporte para ASP.NET y VB.NET

> SQL Server

- Conocimientos:

> Familiaridad con desarrollo en ASP.NET y manejo de bases de datos SQL.

## 📄 Licencia
Este proyecto se distribuye bajo la Licencia MIT. Consulta el archivo LICENSE para más información.
