# Connectivity Test Results

## Local Test (on the server)
```bash
curl localhost
```
_Expected: Nginx "Welcome to nginx!" HTML response_
Result: [ paste output ]

## Remote Test (from your local machine)
```bash
curl http://56.228.35.86/
```
Result: [ paste output ]

## Browser Test
Navigate to `http://<public-ip>` in a browser.
Result: [ ✅ / ❌ — attach screenshot to docs/screenshots/ ]

## Port Verification
```bash
sudo ss -tulpn
```
Result: [ paste output — should show 22 (ssh) and 80 (nginx) listening ]

## Firewall Status
```bash
sudo ufw status verbose
```
Result: [ paste output ]

## Negative Test (confirms firewall is working)
Try connecting to a port that should be closed, e.g.:
```bash
nc -zv <public-ip> 8080
```
Result: [ should time out / refuse — confirms only 22 and 80 are exposed ]

---
**Screenshots:** add to `docs/screenshots/` — recommend: EC2 dashboard, Security Group rules, terminal SSH session, browser showing Nginx page.
