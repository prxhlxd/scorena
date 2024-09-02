from flask import Flask , request, jsonify
import flask_cors
import psycopg2
import json

conn = psycopg2.connect(host="localhost",dbname = "scorena",user = "postgres",password = "prahlad123",port = 5432)
app = Flask(__name__)
flask_cors.CORS(app)
@app.route('/player' , methods = ['POST' , 'GET'])
def addPlayer():
    if request.method == "GET":
        conn = psycopg2.connect(host="localhost",dbname = "scorena",user = "postgres",password = "prahlad123",port = 5432)
        cur = conn.cursor()
        cur.execute("""
        Select * from players;
        """)
        a = cur.fetchall()
        json_data = []
        for row in a:
          json_data.append({"player_id": row[0], "team_id": row[2], "position" : row[3] , "name" : row[1] , "jersey" : row[4]})

        json_string = json.dumps(json_data)
        conn.commit()
        cur.close()
        conn.close()
        return json_string
    elif request.method == "POST":
        conn = psycopg2.connect(host="localhost",dbname = "scorena",user = "postgres",password = "prahlad123",port = 5432)
        cur1 = conn.cursor()
        r = request.json
        name = r['pname']
        t_tid = r['teamid']
        pos = r['pos']
        j_no = r['jerseyno']
        cur1.execute("insert into players ( teamid , pos, pname , jerseyno) values ( %s , %s , %s , %s);" , ( t_tid, pos , name , j_no))
        conn.commit()
        cur1.close()
        conn.close()
        return jsonify({"response": "hi "+ name +" has been created!"})

@app.route('/games' , methods = ['GET'])
def gameController():
    conn = psycopg2.connect(host="localhost",dbname = "scorena",user = "postgres",password = "prahlad123",port = 5432)
    cur = conn.cursor()

    cur.execute("Select * from games;")
    games = cur.fetchall()
    cur.execute("Select * from teams;")
    teams = cur.fetchall()

    team_dict = {}
    for row in teams:
        team_dict[row[0]] = row[1]

    json_data = []
    for row in games:
        json_data.append({"gid" : row[0], "homeTeam" : team_dict[row[1]] , "awayTeam" : team_dict[row[2]]})

    json_string = json.dumps(json_data)

    conn.commit()
    cur.close()
    conn.close()
    
    return json_string

@app.route('/team' , methods = ['POST' , 'GET'])
def teamController():
    if request.method == "GET":
        conn = psycopg2.connect(host="localhost",dbname = "scorena",user = "postgres",password = "prahlad123",port = 5432)
        cur = conn.cursor()
        cur.execute("""
            SELECT * FROM teams
            ORDER BY tid ASC;
        """)
        teams = cur.fetchall()
        json_data = []
        for row in teams:
          json_data.append({"tid": row[0], "name": row[1], "coach" : row[2]})

        json_string = json.dumps(json_data)
        return json_string
    elif request.method == "POST":
        conn = psycopg2.connect(host="localhost",dbname = "scorena",user = "postgres",password = "prahlad123",port = 5432)
        cur = conn.cursor()
        cur.execute("""
            SELECT * FROM teams
            ORDER BY tid ASC;
        """)
        teams = cur.fetchall()
        tid = teams[-1][0] + 1
        r = request.json
        name = r['name']
        coach = r['coach']
        cur.execute("insert into teams (tid, tname , coach) values (%s, %s , %s);" , (tid , name , coach))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"response":"Team " + name + " has been created"})

@app.route('/game/<int:gid>' , methods = ['POST' , 'GET'])
def boxScore(gid):
    if request.method == "GET":
        conn = psycopg2.connect(host="localhost",dbname = "scorena",user = "postgres",password = "prahlad123",port = 5432)
        cur = conn.cursor()

        cur.execute("""
            SELECT 
            g.gid AS game_id,  -- You can add this to identify the game
            h.tname AS home_team,
            a.tname AS away_team
            FROM games g
            INNER JOIN teams h ON g.homeid = h.tid  -- Join with teams table for home team
            INNER JOIN teams a ON g.awayid = a.tid
            where gid = %s; -- Join with teams table for away team
        """ , (gid,))
        a = cur.fetchall()
        json_data = []
        #json_data.append({"home" : a[0][1] , "away" : a[0][2]})

        cur.execute("Select * from games where gid = %s" , (gid,))
        b = cur.fetchall()
        home_id = b[0][1]
        away_id = b[0][2]

        cur.execute("Select pid , pname from players where teamid = %s" , (home_id,))
        c = cur.fetchall()
        home_players = {}
        for row in c:
            home_players[row[0]] = row[1]

        cur.execute("Select pid , pname from players where teamid = %s" , (away_id,))
        d = cur.fetchall()
        away_players = {}
        for row in d:
            away_players[row[0]] = row[1]

        cur.execute("Select * from boxscores where gameid = %s" , (gid,))
        e = cur.fetchall()
        home_points = 0
        for row in e:
            if(int(row[0] in home_players)):
                json_data.append({"pname": home_players[int(row[0])], "gid": row[1],  "FG" : row[3] , "FGA" : row[4] , "3P" : row[5] , "3PA" : row[6] , "FT" : row[7] , "FTA" : row[8] , "OR" : row[9] ,"DR" : row[10] , "assist" : row[11] , "steals" : row[12] , "blocks" : row[13] , "turnovers" : row[14] , "PF" : row[15] , "points" : row[16]})
                home_points += int(row[16])
        away_points = 0
        for row in e:
            if(int(row[0] in away_players)):
                json_data.append({"pname": away_players[int(row[0])], "gid": row[1],  "FG" : row[3] , "FGA" : row[4] , "3P" : row[5] , "3PA" : row[6] , "FT" : row[7] , "FTA" : row[8] , "OR" : row[9] ,"DR" : row[10] , "assist" : row[11] , "steals" : row[12] , "blocks" : row[13] , "turnovers" : row[14] , "PF" : row[15] , "points" : row[16]})
                away_points += int(row[16])
        
        #json_data.append({"home" : a[0][1] , "home-score": home_points, "away" : a[0][2] , "away_points" : away_points})
        json_string = json.dumps(json_data)

        conn.commit()
        cur.close()
        conn.close()
        return json_string

    elif request.method == "POST":
        try:
            r = request.json
            event_id = r['event']
            pname = r['player_name']
            # conn = psycopg2.connect(host="localhost",dbname = "scorena",user = "postgres",password = "prahlad123",port = 5432)
            # cur = conn.cursor()
            # cur.execute("CALL update_boxscore(%s , %s , %s)" , (event_id , gid, player_id))
            # conn.commit()
            # cur.close()
            # conn.close()
            conn = psycopg2.connect(host="localhost",dbname = "scorena",user = "postgres",password = "prahlad123",port = 5432)
            cur = conn.cursor()
            cur.execute("""
                SELECT 
                g.gid AS game_id,  -- You can add this to identify the game
                h.tname AS home_team,
                a.tname AS away_team
                FROM games g
                INNER JOIN teams h ON g.homeid = h.tid  -- Join with teams table for home team
                INNER JOIN teams a ON g.awayid = a.tid
                where gid = %s; -- Join with teams table for away team
            """ , (gid,))
            a = cur.fetchall()
            json_data = []

            cur.execute("Select * from games where gid = %s" , (gid,))
            b = cur.fetchall()
            home_id = b[0][1]
            away_id = b[0][2]

            cur.execute("Select pid , pname from players where teamid = %s" , (home_id,))
            c = cur.fetchall()
            players = {}
            for row in c:
                players[row[1]] = row[0]

            cur.execute("Select pid , pname from players where teamid = %s" , (away_id,))
            d = cur.fetchall()
            away_players = {}
            for row in d:
                players[row[1]] = row[0]

            cur.execute("CALL update_boxscore(%s , %s , %s)" , (event_id , gid, players[pname]))

            conn.commit()
            cur.close()
            conn.close()
            return jsonify({"response": "Form is successful!"})
        except psycopg2.Error as e:
            error_code = e.pgerror
            hi = {"response" : error_code[:64]}
            return jsonify(hi)
@app.route('/gamedetails/<int:gid>' , methods = ['GET'])
def gamedetails(gid):
    if request.method == "GET":
        conn = psycopg2.connect(host="localhost",dbname = "scorena",user = "postgres",password = "prahlad123",port = 5432)
        cur = conn.cursor()

        cur.execute("""
            SELECT 
            g.gid AS game_id,  -- You can add this to identify the game
            h.tname AS home_team,
            a.tname AS away_team
            FROM games g
            INNER JOIN teams h ON g.homeid = h.tid  -- Join with teams table for home team
            INNER JOIN teams a ON g.awayid = a.tid
            where gid = %s; -- Join with teams table for away team
        """ , (gid,))
        a = cur.fetchall()
        json_data = []

        cur.execute("Select * from games where gid = %s" , (gid,))
        b = cur.fetchall()
        home_id = b[0][1]
        away_id = b[0][2]

        cur.execute("Select pid , pname from players where teamid = %s" , (home_id,))
        c = cur.fetchall()
        home_players = {}
        for row in c:
            home_players[row[0]] = row[1]

        cur.execute("Select pid , pname from players where teamid = %s" , (away_id,))
        d = cur.fetchall()
        away_players = {}
        for row in d:
            away_players[row[0]] = row[1]

        cur.execute("Select * from boxscores where gameid = %s" , (gid,))
        e = cur.fetchall()
        home_points = 0
        for row in e:
            if(int(row[0] in home_players)):
                home_points += int(row[16])
        away_points = 0
        for row in e:
            if(int(row[0] in away_players)):
                away_points += int(row[16])
        
        json_string = jsonify({"home" : a[0][1] , "home_score": home_points, "away" : a[0][2] , "away_points" : away_points})

        conn.commit()
        cur.close()
        conn.close()
        return json_string

if __name__ == "__main__":
    app.run(debug = True , host= '0.0.0.0' , port = 8080)

conn.commit()
conn.close()