# 彩云影视
 ( [English Version](EnglishREADME.md) | 中文版本)
 ## 基本说明
 1. 此版本针对中国大陆地区使用
 2. 此版本不提供相关影片资源的解析服务，该服务由第三方使用者自行提供
 3. 此版本针对**电视盒子**设计，部分功能不支持触摸操作
 4. 请在安卓***API>=19***的设备上使用
 5. 此版本自身不含广告，请勿相信第三方修改版本
## APP接口说明
### 搜索接口
#### APP请求参数
| 接口名称 | 方法 | 地址 | 所含参数 | 类型 | 参数说明 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 影视搜索 | GET | /search | name | String | 影片名称 |
| | | | wd | String | 固定值"submit" |
#### 返回值
| 名称 | 参数类型 | 说明 |
| :---: | :---: | :---: |
| hosts | []string | 资源站名称 |
| 站名称 | string | 可变 |
| station | string | 站点名称 |
| infos | list | 搜索结果 |
| name | string | 影片名称 |
| path | string | 影片信息页地址 |
| state | string | 影片更新状态 |
#### 返回值示例

    {
    "hosts" : [ "a", "b", "c" ],
        "a" : {
            "station" : "A站点",
            "infos" : [
                {"name": "影片名称",
                "path" : "影片Path",
                "state" : "更新至第5集"},
            ],
        },
        "b" : {
            "station" : "B站点",
            "infos" : []
        },
        "c" : {
            "station" : "C站点",
            "infos" : [
                {"name" : "影片名称",
                "path" : "影片Path",
                "state" : "完结"}
            ]
        }
    }

### 视频信息页接口
#### APP请求参数
| 接口名称 | 方法 | 地址 | 所含参数 | 类型 | 参数说明 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 请求影片信息 | GET | /videolink | station | string | 站点名称 |
| | | | path | string | 对应影片Path |

#### 返回参数
| 名称 | 参数类型 | 说明 |
| :---: | :---: | :---: |
| title | string | 影片名称 |
| actors | string | 演员名单 |
| imgpath | string | 封面图片 |
| year | string | 年份 |
|content| string | 剧情简介 |
| items | List | 剧集播放地址与标签 |
| m3u8 | string | M3U8播放地址 |
| label | string | 标签 |
#### 返回值示例
    {
        "title":"回XXX儿",
        "actors":"X婷,李X文,丁X丽...",
        "imgpath":"https://xxxx.com/upload/20221221-1/8c095.jpg",
        "year":"2022",
        "content":"X家失踪多年的女儿突然出现,这突如其来的团聚反而让小镇风波不断。意外和真相接踵而至，X家人深藏的秘密也逐渐浮出",
        "items":[
                {
                "m3u8":"https://xxxxx.com/20221221/86/index.m3u8",
                "label":"第01集"
                },
                {
                "m3u8":"https://xxxxx.com/20221221/Pw/index.m3u8",
                "label":"第02集"},
                {
                "m3u8":"https://xxxxx.com/20221221/cZ/index.m3u8",
                "label":"第03集"
                },
            ]
    }
### 影视推荐接口
#### APP请求参数
| 接口名称 | 方法 | 地址 | 所含参数 | 类型 | 参数说明 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 影视推荐接口 | GET | /recomVideo | index | string | 请求的类型 |
#### 返回参数
| 名称 | 参数类型 | 说明 |
| :---: | :---: | :---: |
| total | List | 推荐影片列表 |
| title | string | 影片名 |
| rate | string | 评分 |
| img | string | 封面图片地址 |
#### 返回值示例
    {
        "total":[
            {
                "title":"法xx凶",
                "rate":"6.7",
                "img":"https://p2877844451.jpg"
                },
            {
                "title":"血战xxx克",
                "rate":"7.0",
                "img":"https://p2589477822.jpg"
            },
            {
                "title":"《真爱至上》的....年后",
                "rate":"8.3",
                "img":"https://p2887209829.jpg"
            },
            {
                "title":"假xx姆",
                "rate":"5.8",
                "img":"https://p2883733361.jpg"
            },
            ]
    }
### 电视直播接口
#### APP请求参数
| 接口名称 | 方法 | 地址 | 所含参数 | 类型 | 参数说明 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 电视直播源请求 | GET | /tvLive | name | string | 频道名称(小写)|
| | | | id | int | 请求次数(自动生成) |
#### 返回参数
| 名称 | 参数类型 | 说明 |
| :---: | :---: | :---: |
| reqid | int | 回应的请求次数 |
| streamlist | []string | 直播源 |
#### 返回值示例
    {
        "reqid":3,
        "streamlist":[
            "http://mnf.m3u8",
            "http://index.m3u8",
            "http://index.m3u8?",
            "http://index.m3u8"
            ]
    }
### APP更新请求接口
**暂无**
### APP搜索栏下方影视推荐
**暂无**