'''
author : Seob 
Description : musteat home
Date : 2024.09.25
Usage :   
'''

from fastapi import FastAPI, File, UploadFile
from fastapi.responses import FileResponse
import pymysql
import os #directory 만들기, 이동
import shutil

app = FastAPI()

# uploads = 폴더이름
UPLOAD_FOLDER = 'uploads' 

#uploads 폴더가 없으면 새로 만들기
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

def connection():
    conn = pymysql.connect(
        host='127.0.0.1',
        user='root',
        password='qwer1234',
        charset='utf8',
        db='musteat'
    )
    return conn

# select
@app.get('/select')
async def select(user_id :str ):
    conn = connection()
    curs = conn.cursor()

    sql = 'select * from restaurant where user_id=%s' # 이름으로 정렬
    curs.execute(sql,(id))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return { 'results' : rows}
        

# 이미지 
@app.get('/view/{file_name}')
async def get_file(file_name : str):
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {'results' : 'error'}


# insert
@app.get('/insert')
async def insert(name:str=None, phone:str=None, lat:str=None, longtitude:str=None, image:str=None, estimate:str=None, user_id:str =None):
    conn = connection()
    curs = conn.cursor()
    
    try:
        sql = "insert into restaurant(name, phone, lat, longtitude, image, estimate, user_id) values (%s,%s,%s,%s,%s,%s,%s)"
        curs.execute(sql,(name,phone,lat,longtitude,image,estimate,user_id))
        conn.commit()
        conn.close()
        return {'result': "ok"}
    except Exception as e:
        conn.close()
        print("error:",e)
        return {'result' : 'error'}




# 이미지 파일 업로드 후에 insert
@app.post('/upload')
async def upload_file(file:UploadFile=File(...)):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file.filename) # path에 uploads, flutter filename join 
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        return {'result' : 'OK'}
    except Exception as e :
        print('Error:',e)
        return {'result': 'error'}

# update only text
@app.get('/update')
async def update(seq = str,name:str=None, phone:str=None,estimate:str=None ):
    conn = connection()
    curs = conn.cursor()
    
    try:
        sql = "update address set name=%s, phone=%s, estimate=%s where seq=%s"
        curs.execute(sql,(name,phone,estimate,seq))
        conn.commit()
        conn.close()
        return {'result': "ok"}
    except Exception as e:
        conn.close()
        print("error:",e)
        return {'result' : 'error'}

# update all
@app.get('/updateAll')
async def updateAll(seq = str,name:str=None, phone:str=None,image:str=None, estimate:str=None ):
    conn = connection()
    curs = conn.cursor()
    
    try:
        sql = "update address set name=%s, phone=%s, image=%s, estimate=%s where seq=%s"
        curs.execute(sql,(name,phone,image,estimate,seq))
        conn.commit()
        conn.close()
        return {'result': "ok"}
    except Exception as e:
        conn.close()
        print("error:",e)
        return {'result' : 'error'}
    

# 이미지 수정할 때
# 이미지 파일 삭제 후 다시 업로드하기
@app.delete('/deleteFile/{file_name}')
async def delete_file(file_name:str):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
        return {'result': 'ok'}
    except Exception as e:
        print("Error:",e)
        return {'result':'error'}

@app.get('/remove')
async def remove(seq : str):
    delete_file
    conn = connection()
    curs = conn.cursor()

    try: 
        sql = 'delete from restuarant where seq=%s'
        curs.execute(sql,(seq))
        conn.commit()
        conn.close()
        return {'result' : 'ok'}
    except Exception as e:
        conn.close()
        print('Error:',e)
        return {'result' : 'error'}

if __name__ == "__main":
    import uvicorn
    uvicorn.run(app, host='127.0.0.1', port=8000)
