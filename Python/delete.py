from fastapi import FastAPI, File, UploadFile
from fastapi.responses import FileResponse
import pymysql
import os
import shutil

app = FastAPI()

UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

def connect():
    conn = pymysql.connect(
        host='127.0.0.1',
        user='root',
        password='qwer1234',
        db='musteat',
        charset='utf8'
    )
    return conn

@app.get("/delete")
async def delete(seq: str=None):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = 'delete from restaurant where seq=%s'
        curs.execute(sql,(seq))
        conn.commit()
        conn.close()
        return {'result': 'OK'}
    except Exception as e:
        conn.close()
        print("Error:",e)
        return {'result':'Error'}
    
    
@app.delete("/deleteFile/{file_name}")
async def delete_file(file_name: str):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
        return {'result':'Ok'}
    except Exception as e:
        print("Error:", e)
        return {'result': 'Error'}