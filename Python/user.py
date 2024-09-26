from fastapi import APIRouter
import pymysql

userRouter = APIRouter()


def connection():
    conn = pymysql.connect(
        host='192.168.50.91',
        user='root',
        password='qwer1234',
        charset='utf8',
        db='musteat'
    )
    return conn
    



# 회원가입 페이지 - id확인(중복검사) : select
@userRouter.get('/check')
async def idcheck(id : str):
    conn = connection()
    curs = conn.cursor()

    sql = 'select count(id) from user where id=%s'
    curs.execute(sql,(id))
    rows = curs.fetchall()
    conn.close()
    print(rows[0][0])
    return {'result': rows}[0][0]


# 회원가입 완료 - id, pw입력 : insert
@userRouter.get('/signup')
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
@userRouter.get('/login')
async def login(id:str=None, pw:str=None):
    conn= connection()
    curs = conn.cursor()
    sql = 'select count(id) from user where id=%s and pw=%s'
    curs.execute(sql,(id,pw))
    rows = curs.fetchall()
    conn.close()
    print(rows[0][0])
    return {'result' : rows[0][0]}