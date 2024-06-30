var exec = require("child_process").exec;

function keep_web_alive() {
  exec("pgrep -laf sing-box", function (err, stdout, stderr) {
    if (stdout.includes("sing-box run -c")) {
      console.log("sing-box 正在运行");
    } else {
      exec(
        "nohup bash entrypoint.sh 2>/dev/null 2>&1 &",
        function (err, stdout, stderr) {
          if (err) {
            console.log("保活-调起 sing-box 命令执行执行错误:" + err);
          } else {
            console.log("保活-调起 sing-box 命令行执行成功!");
          }
        }
      );
    }
  });
}
setInterval(keep_web_alive, 10 * 1000);

exec("bash entrypoint.sh", function (err, stdout, stderr) {
  if (err) {
    console.error(err);
    return;
  }
  console.log(stdout);
});
