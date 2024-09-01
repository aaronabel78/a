from telegram import Update, InputFile
from telegram.ext import Application, CommandHandler, ContextTypes
import requests

# Tu token de Telegram
TOKEN = '7485425791:AAGobTAOMR1TIKtiNGbB96VWoimRF9wCSMw'

# URL base de la API
API_BASE_URL = 'https://ricardoaplicaciones-qu4k.onrender.com/api/federador/'

# Lista de IDs permitidos
ALLOWED_USERS = {1857751671, 7298433270}

def format_data(data):
    sisa = data['data']['sisa']
    return (
        f"**Datos Encontrados:**\n\n"
        f"**ID:** {sisa['id']}\n"
        f"**Código SISA:** {sisa['codigoSISA']}\n"
        f"**DNI:** {sisa['nroDocumento']}\n"
        f"**Nombre:** {sisa['nombre']}\n"
        f"**Apellido:** {sisa['apellido']}\n"
        f"**Sexo:** {sisa['sexo']}\n"
        f"**Fecha de Nacimiento:** {sisa['fechaNacimiento']}\n"
        f"**Provincia:** {sisa['provincia']}\n"
        f"**Localidad:** {sisa['localidad']}\n"
        f"**Domicilio:** {sisa['domicilio']}\n"
        f"**Código Postal:** {sisa['codigoPostal']}\n"
        f"**País de Nacimiento:** {sisa['paisNacimiento']}\n"
        f"**Fallecido:** {sisa['fallecido']}\n"
    )

def save_data_to_file(data, filename='datos.txt'):
    with open(filename, 'w') as file:
        file.write(data)

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if update.effective_user.id in ALLOWED_USERS:
        await update.message.reply_text(
            'Bienvenido al bot, soy un bot creado con el fin de buscar información.\n'
            'Fui creado por ARX o más conocido como t.me/aaronnnmdb\n\n'
            'Comandos:\n'
            '/dni <número> <M/F> para buscar los datos.\n'
            'F = Femenino\n'
            'M = Masculino'
        )
    else:
        await update.message.reply_text('No estás autorizado para usar este bot.')

async def buscar_dni(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if update.effective_user.id in ALLOWED_USERS:
        if len(context.args) == 2:
            dni = context.args[0]
            genero = context.args[1].upper()
            
            if genero in ['M', 'F']:
                # Enviar mensaje de espera
                await update.message.reply_text('Buscando información🗂️, sea paciente.')
                
                # Construimos la URL de la API con el DNI y el género
                api_url = f"{API_BASE_URL}{dni}/{genero}"
                response = requests.get(api_url)
                
                if response.status_code == 200:
                    datos = response.json()
                    formatted_data = format_data(datos)
                    
                    # Guardar datos en archivo
                    save_data_to_file(formatted_data)
                    
                    # Enviar datos formateados y el archivo
                    await update.message.reply_text(formatted_data, parse_mode='Markdown')
                    with open('datos.txt', 'rb') as file:
                        await update.message.reply_document(document=InputFile(file, filename='datos.txt'))
                else:
                    await update.message.reply_text('No se encontraron datos o hubo un error con la API.')
            else:
                await update.message.reply_text('El género debe ser "M" para masculino o "F" para femenino.')
        else:
            await update.message.reply_text('Por favor, proporciona un número de DNI y un género (M/F).')
    else:
        await update.message.reply_text('No estás autorizado para usar este bot.')

def main() -> None:
    application = Application.builder().token(TOKEN).build()

    # Agregar manejadores de comandos
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("dni", buscar_dni))

    # Iniciar el bot
    application.run_polling()

if __name__ == '__main__':
    main()
