const fs = require('fs');
const path = require('path');

// Función para insertar los elementos en la tabla de Carnes en el HTML
function insertIntoHtml(data, lines) {
    const tbodyIndex = data.indexOf('<tbody>', data.indexOf('<u>Carnes</u>')) + 7;
    const tbodyCloseIndex = data.indexOf('</tbody>', tbodyIndex);
    let tableContent = '';
    lines.forEach((line, index) => {
        if (line.trim()) {
            const [element, price] = line.split(':');
            tableContent += `
                <tr>
                    <th scope="row">${index + 1}</th>
                    <td colspan="2">${element.trim()}</td>
                    <td>${price.trim()}</td>
                </tr>`;
        }
    });
    return data.slice(0, tbodyIndex) + tableContent + data.slice(tbodyCloseIndex);
}

// Función para leer y procesar el archivo de texto y HTML
function updateHtmlWithTextData(htmlFilePath, textFilePath) {
    // Leer el archivo HTML
    fs.readFile(htmlFilePath, { encoding: 'utf-8' }, (err, htmlData) => {
        if (err) {
            return console.error('Failed to read HTML file:', err);
        }

        // Leer el archivo de texto
        fs.readFile(textFilePath, { encoding: 'utf-8' }, (err, textData) => {
            if (err) {
                return console.error('Failed to read text file:', err);
            }

            const lines = textData.split('\n');
            const updatedHtml = insertIntoHtml(htmlData, lines);

            // Guardar el HTML actualizado
            fs.writeFile(htmlFilePath, updatedHtml, err => {
                if (err) {
                    console.error('Failed to write updated HTML file:', err);
                } else {
                    console.log('HTML file has been updated successfully.');
                }
            });
        });
    });
}

const htmlFilePath = path.join(__dirname, 'carta.html');
const textFilePath = path.join(__dirname, 'carta_carnes.txt');

updateHtmlWithTextData(htmlFilePath, textFilePath);
