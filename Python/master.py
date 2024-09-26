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

#192.168.50.91
def connection():
    conn = pymysql.connect(
        host='192.168.50.91',
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
    curs.execute(sql,(user_id))
    rows = curs.fetchall()
    conn.close()

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
async def insert(name:str=None, phone:str=None, latitude:str=None, longitude:str=None, image:str=None, estimate:str=None, rating : str=None, user_id:str =None):
    conn = connection()
    curs = conn.cursor()
    
    try:
        sql = "insert into restaurant(name, phone, latitude, longitude, image, estimate, rating,user_id) values (%s,%s,%s,%s,%s,%s,%s,%s)"
        curs.execute(sql,(name,phone,latitude,longitude,image,estimate,rating,user_id))
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
async def update(seq = str,name:str=None, phone:str=None,estimate:str=None, rating:str=None ):
    conn = connection()
    curs = conn.cursor()
    
    try:
        sql = "update restaurant set name=%s, phone=%s, estimate=%s, rating=%s where seq=%s"
        curs.execute(sql,(name,phone,estimate,rating,seq))
        conn.commit()
        conn.close()
        return {'result': "ok"}
    except Exception as e:
        conn.close()
        print("error:",e)
        return {'result' : 'error'}

# update all
@app.get('/updateAll')
async def updateAll(seq = str,name:str=None, phone:str=None,image:str=None, estimate:str=None, rating: str=None ):
    conn = connection()
    curs = conn.cursor()
    
    try:
        sql = "update restaurant set name=%s, phone=%s, image=%s, estimate=%s, rating=%s where seq=%s"
        curs.execute(sql,(name,phone,image,estimate,rating,seq))
        conn.commit()
        conn.close()
        return {'result': "ok"}
    except Exception as e:
        conn.close()
        print("error:",e)
        return {'result' : 'error'}
    

# test data : yubee 333/ jangbee 111 / gwanwoo 123
# 회원가입 페이지 - id확인(중복검사) : select
@app.get('/check')
async def idcheck(id : str):
    conn = connection()
    curs = conn.cursor()

    sql = 'select count(id) from user where id=%s'
    curs.execute(sql,(id))
    rows = curs.fetchall()
    conn.close()
    print(rows[0][0])
    return {'result': rows[0][0]}


# 회원가입 완료 - id, pw입력 : insert
@app.get('/signup')
async def insertUser(id :str, pw : str):
    conn = connection()
    curs = conn.cursor()

    try:
        sql = 'insert into user(id, pw) values (%s,%s)'
        curs.execute(sql,(id,pw))
        conn.commit()
        conn.close()
        return {'result' : 'ok'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : 'Error'} 
    

# 로그인 - id, pw 확인 - select
@app.get('/login')
async def login(id:str=None, pw:str=None):
    conn= connection()
    curs = conn.cursor()
    sql = 'select count(id) from user where id=%s and pw=%s'
    curs.execute(sql,(id,pw))
    rows = curs.fetchall()
    conn.close()
    print(rows[0][0])
    return {'result' : rows[0][0]}

# db삭제
@app.get("/delete")
async def delete(seq: str=None):
    conn = connection()
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
    
    
    # 이미지 파일 삭제
@app.delete("/deleteFile/{file_name}")
async def delete_file(file_name: str):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
        return {'result':'OK'}
    except Exception as e:
        print("Error:", e)
        return {'result': 'Error'}

    # 평점 검색(drop down)
@app.get('/sort')
async def sort_rating(rating:str, user_id:str):
    conn = connection()
    curs = conn.cursor()
    sql = 'select * from restaurant where rating like %s and user_id=%s'
    curs.execute(sql,(rating,user_id))
    rows = curs.fetchall()
    conn.close()
    return {'result' : rows}


if __name__ == "__main":
    import uvicorn
    uvicorn.run(app, host='127.0.0.1', port=8000)
