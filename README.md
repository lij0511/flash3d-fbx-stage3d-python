FbxParser
=========

Runtime Requirements
------------------
* Python2.7
* Fbxsdk 2015.1

运行环境
------------------
* Python2.7
* Fbxsdk 2015.1

Downloads
------------------
* Python2.7		https://www.python.org/downloads/ 
* Fbxsdk 2015.1		http://usa.autodesk.com/adsk/servlet/pc/item?siteID=123112&id=10775847

下载地址
------------------
* Python2.7		https://www.python.org/downloads/ 
* Fbxsdk 2015.1		http://usa.autodesk.com/adsk/servlet/pc/item?siteID=123112&id=10775847

To install Python FBX:
------------------
* Copy the contents of yourFBXSDKpath\lib\<Pythonxxxxxx>\ into:
* Windows: yourPythonPath\Lib\site-packages\
* Mac OSX: /Library/Python/x.x/site-packages/
* Linux  : /usr/local/lib/pythonx.x/site-packages/

如何安装 Python FBX:
------------------
* 拷贝 Fbxsdk安装目录\lib\<Pythonxxxxxx>\ into:
* Windows: Python安装目录\Lib\site-packages\
* Mac OSX: /Library/Python/x.x/site-packages/
* Linux  : /usr/local/lib/pythonx.x/site-packages/

How to Use
----------
   * put FbxParser.py and fbx file together
   * Windos: Double click FbxParser.py
   * Mac   : open terminal. locate to fbx file directory. run:python FbxParser.py

使用
----------
   * 将 FbxParser.py与fbx文件放置到一起
   * Windos: 双击FbxParser.py
   * Mac   : 定位到fbx文件目录,运行:python FbxParser.py
   
Option
----------
   * -normal:parse normals
   * -uv0   :parse uv0
   * -uv1   :parse uv1
   * -anim  :parse animation
   * -world :parse use global transform
   * -path  :assign fbxfile
   
脚本参数
----------
   * -normal:解析法线
   * -uv0   :解析uv0
   * -uv1   :解析uv1
   * -anim  :解析动画
   * -world :使用全局空间
   * -path  :指定fbx文件
   
其它
----------
   * Fbx文件名、Fbx文件路径、模型、贴图以及其它均不能使用中文
   * 详细使用方法阅读脚本头注释


	
