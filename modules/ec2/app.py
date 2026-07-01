from flask import Flask, request, render_template_string, redirect
import pymysql, os

app = Flask(__name__)

def get_db():
    return pymysql.connect(
        host     = os.environ['DB_HOST'],
        user     = os.environ['DB_USER'],
        password = os.environ['DB_PASS'],
        database = os.environ['DB_NAME'],
        cursorclass = pymysql.cursors.Cursor,
        autocommit  = True
    )

def init_db():
    conn = get_db()
    cur  = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS employees (
            id          INT AUTO_INCREMENT PRIMARY KEY,
            first_name  VARCHAR(100) NOT NULL,
            last_name   VARCHAR(100) NOT NULL,
            email       VARCHAR(150) NOT NULL UNIQUE,
            department  VARCHAR(100) NOT NULL,
            role        VARCHAR(100) NOT NULL,
            salary      DECIMAL(10,2) NOT NULL,
            start_date  DATE NOT NULL,
            status      ENUM('active','inactive') DEFAULT 'active',
            created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    cur.close()
    conn.close()

HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Employee Management</title>
  <style>
    *{margin:0;padding:0;box-sizing:border-box}
    body{font-family:'Segoe UI',Arial,sans-serif;background:#0f1117;color:#e5e7eb;min-height:100vh}
    header{background:#1a1d27;border-bottom:1px solid #2e3250;padding:18px 40px;display:flex;align-items:center;justify-content:space-between}
    header h1{font-size:22px;color:#fff}
    header span{background:#2563eb;color:#fff;font-size:11px;font-weight:700;padding:4px 12px;border-radius:20px;letter-spacing:1px;text-transform:uppercase}
    .container{max-width:1100px;margin:40px auto;padding:0 20px}
    .card{background:#1a1d27;border:1px solid #2e3250;border-radius:12px;padding:30px;margin-bottom:30px}
    .card h2{font-size:16px;color:#9ca3af;text-transform:uppercase;letter-spacing:1px;margin-bottom:20px}
    .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:14px}
    input,select{width:100%;background:#0f1117;border:1px solid #2e3250;border-radius:8px;padding:10px 14px;color:#e5e7eb;font-size:14px;outline:none}
    input:focus,select:focus{border-color:#2563eb}
    .btn{background:#2563eb;color:#fff;border:none;border-radius:8px;padding:11px 28px;font-size:14px;font-weight:600;cursor:pointer;transition:background .2s}
    .btn:hover{background:#1d4ed8}
    .btn-danger{background:#dc2626}
    .btn-danger:hover{background:#b91c1c}
    table{width:100%;border-collapse:collapse;font-size:14px}
    th{text-align:left;padding:12px 16px;color:#6b7280;font-size:11px;text-transform:uppercase;letter-spacing:1px;border-bottom:1px solid #2e3250}
    td{padding:14px 16px;border-bottom:1px solid #1f2235;color:#d1d5db}
    tr:hover td{background:#1f2235}
    .badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700}
    .active{background:#052e16;color:#4ade80}
    .inactive{background:#3b0000;color:#f87171}
    .stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:16px;margin-bottom:30px}
    .stat{background:#1a1d27;border:1px solid #2e3250;border-radius:12px;padding:20px 24px}
    .stat .num{font-size:32px;font-weight:700;color:#2563eb}
    .stat .label{font-size:12px;color:#6b7280;margin-top:4px}
    .msg{padding:12px 16px;border-radius:8px;margin-bottom:20px;font-size:14px}
    .success{background:#052e16;color:#4ade80;border:1px solid #166534}
    .error{background:#3b0000;color:#f87171;border:1px solid #991b1b}
    @media(max-width:600px){.grid{grid-template-columns:1fr}}
  </style>
</head>
<body>
  <header>
    <h1>&#128188; Employee Management</h1>
    <span>{{ env }}</span>
  </header>
  <div class="container">
    {% if msg %}<div class="msg {{ msg_type }}">{{ msg }}</div>{% endif %}
    <div class="stats">
      <div class="stat"><div class="num">{{ stats.total }}</div><div class="label">Total Employees</div></div>
      <div class="stat"><div class="num">{{ stats.active }}</div><div class="label">Active</div></div>
      <div class="stat"><div class="num">{{ stats.inactive }}</div><div class="label">Inactive</div></div>
      <div class="stat"><div class="num">${{ stats.avg_salary }}</div><div class="label">Avg Salary</div></div>
    </div>
    <div class="card">
      <h2>Add Employee</h2>
      <form method="POST" action="/add">
        <div class="grid">
          <input name="first_name" placeholder="First Name" required>
          <input name="last_name"  placeholder="Last Name" required>
          <input name="email"      placeholder="Email" type="email" required>
          <input name="department" placeholder="Department" required>
          <input name="role"       placeholder="Job Title" required>
          <input name="salary"     placeholder="Salary" type="number" step="0.01" required>
          <input name="start_date" placeholder="Start Date" type="date" required>
          <select name="status">
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
          </select>
        </div>
        <br>
        <button class="btn" type="submit">Add Employee</button>
      </form>
    </div>
    <div class="card">
      <h2>All Employees ({{ employees|length }})</h2>
      <table>
        <thead>
          <tr>
            <th>Name</th><th>Email</th><th>Department</th>
            <th>Role</th><th>Salary</th><th>Start Date</th>
            <th>Status</th><th>Action</th>
          </tr>
        </thead>
        <tbody>
          {% for e in employees %}
          <tr>
            <td>{{ e[1] }} {{ e[2] }}</td>
            <td>{{ e[3] }}</td>
            <td>{{ e[4] }}</td>
            <td>{{ e[5] }}</td>
            <td>${{ "%.2f"|format(e[6]|float) }}</td>
            <td>{{ e[7] }}</td>
            <td><span class="badge {{ e[8] }}">{{ e[8] }}</span></td>
            <td>
              <form method="POST" action="/delete/{{ e[0] }}" style="display:inline">
                <button class="btn btn-danger" type="submit">Delete</button>
              </form>
            </td>
          </tr>
          {% else %}
          <tr><td colspan="8" style="text-align:center;color:#6b7280;padding:30px">No employees yet. Add one above.</td></tr>
          {% endfor %}
        </tbody>
      </table>
    </div>
  </div>
</body>
</html>
"""

@app.route('/', methods=['GET'])
def index():
    conn = get_db(); cur = conn.cursor()
    cur.execute("SELECT * FROM employees ORDER BY created_at DESC")
    employees = cur.fetchall()
    cur.execute("SELECT COUNT(*), SUM(status='active'), SUM(status='inactive'), ROUND(AVG(salary),2) FROM employees")
    row = cur.fetchone()
    cur.close(); conn.close()
    stats = {
        'total':      row[0] or 0,
        'active':     row[1] or 0,
        'inactive':   row[2] or 0,
        'avg_salary': row[3] or '0.00'
    }
    msg      = request.args.get('msg', '')
    msg_type = request.args.get('type', 'success')
    return render_template_string(HTML, employees=employees, stats=stats,
                                  env=os.environ.get('ENVIRONMENT', 'dev'),
                                  msg=msg, msg_type=msg_type)

@app.route('/add', methods=['POST'])
def add():
    try:
        conn = get_db(); cur = conn.cursor()
        cur.execute("""
            INSERT INTO employees (first_name,last_name,email,department,role,salary,start_date,status)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
        """, (
            request.form['first_name'], request.form['last_name'],
            request.form['email'],      request.form['department'],
            request.form['role'],       request.form['salary'],
            request.form['start_date'], request.form['status']
        ))
        cur.close(); conn.close()
        return redirect('/?msg=Employee added successfully&type=success')
    except Exception as ex:
        return redirect(f'/?msg=Error: {str(ex)}&type=error')

@app.route('/delete/<int:emp_id>', methods=['POST'])
def delete(emp_id):
    conn = get_db(); cur = conn.cursor()
    cur.execute("DELETE FROM employees WHERE id=%s", (emp_id,))
    cur.close(); conn.close()
    return redirect('/?msg=Employee deleted&type=success')

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=80)
