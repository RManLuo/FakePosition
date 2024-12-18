# FakePosition

修改IOS设备的位置信息，支持IOS 17+。

IOS 18+ 需要python>3.13，同时升级pymobiledevice3。

## 使用方法

必须使用MAC电脑，使用USB连接IOS设备。
1. 安装依赖

   ```shell
   python3 -m pip install -U pymobiledevice3
   ```
2. 增加可执行权限

   ```shell
   chmod +x change_ios_position.sh
   ```

3. 修改位置信息

   ```shell
   change_ios_position.sh ${latitude} ${longitude}
   ```

### 例子
```shell
sudo ./change_ios_position.sh -27.32112 153.06814
```

## 参考
* https://github.com/doronz88/pymobiledevice3
* https://shawnhuangyh.com/post/ios-17-location-simulation/
