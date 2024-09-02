# from flask import Flask , request, jsonify
# import psycopg2
# import json
# import app

# conn = psycopg2.connect(host="localhost",dbname = "scorena",user = "postgres",password = "prahlad123",port = 5432)
# cur = conn.cursor()
# gid = 2003
# cur.execute("""
#     SELECT 
#     g.gid AS game_id,  -- You can add this to identify the game
#     h.tname AS home_team,
#     a.tname AS away_team
#     FROM games g
#     INNER JOIN teams h ON g.homeid = h.tid  -- Join with teams table for home team
#     INNER JOIN teams a ON g.awayid = a.tid
#     where gid = %s; -- Join with teams table for away team
# """ , (gid,))
# a = cur.fetchall()
# json_data = []

# cur.execute("Select * from games where gid = %s" , (gid,))
# b = cur.fetchall()
# home_id = b[0][1]
# away_id = b[0][2]

# cur.execute("Select pid , pname from players where teamid = %s" , (home_id,))
# c = cur.fetchall()
# players = {}
# for row in c:
#     players[row[1]] = row[0]

# cur.execute("Select pid , pname from players where teamid = %s" , (away_id,))
# d = cur.fetchall()
# away_players = {}
# for row in d:
#     players[row[1]] = row[0]

# cur.execute("CALL update_boxscore(%s , %s , %s)" , (event_id , gid, players[pname]))

# conn.commit()
# cur.close()
# conn.close()

