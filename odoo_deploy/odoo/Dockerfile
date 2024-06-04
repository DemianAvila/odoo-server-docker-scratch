FROM            python:3.10.14-bullseye
RUN             apt update -y 
RUN             apt install git libsasl2-dev python-dev-is-python3 libldap2-dev libssl-dev -y
RUN             git clone https://github.com/odoo/odoo.git --depth 1 --branch 17.0 
RUN             git clone https://github.com/odoo/runbot.git --depth 1 --branch 17.0
WORKDIR         /odoo
RUN             pip install --upgrade pip
RUN             pip install -r requirements.txt
CMD             python3 odoo-bin  --db_host=db --db_port=5432  --db_user=odoo  --db_password=odoo -d odoo --init --stop-after-init
