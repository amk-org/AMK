<html>
<head lang="en">
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0, user-scalable=no">

    <!-- [if lt IE 9]>
	<script src="{{ static_url('js/html5shiv.js') }}"></script>
	<script src="{{ static_url('js/respond.min.js') }}"></script>
    -->

    <title>舞客</title>

    <link href="{{ static_url('css/bootstrap.min.css') }}" rel="stylesheet">
    <link href="{{ static_url('css/font-awesome.min.css') }}" rel="stylesheet">
    <link href="{{ static_url('css/jquery.bxslider.css') }}" rel="stylesheet">
    <link href="{{ static_url('css/main.css') }}" rel="stylesheet">

</head>
<body>

<div id="header">
    <nav class="navbar navbar-default navbar-static-top navbar-white-ver">
        <div class="container">
            <div>
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#header-navbar-collapse" aria-expanded="false">
                        <span class="sr-only">Toggle navigate</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href="/">
                        AMK
                    </a>
                </div>

                <div class="collapse navbar-collapse" id="header-navbar-collapse">
                    <ul class="nav navbar-nav">
                        <li class="active"><a href="/"><span>首页</span></a></li>
                        <li><a href="/contests"><span>赛事</span></a></li>
                        <li><a href = "/userspace/bedancer"><span>个人空间</span></a></li>
                    </ul>

                    <div class="navbar-form navbar-left">
                        <div class="input-group">
                            <input type="text" class="form-control" placeholder="比赛关键词...">
                                <span class="input-group-btn">
                                    <button id="searchSite" class="btn btn-danger" type="button"><i class="fa fa-search"></i></button>
                                </span>
                        </div>
                    </div>

                    <ul class="nav navbar-nav navbar-right">
                        <li> <a href="#">登录 | 注册</a></li>
                        <li><a href="#" class="folder hide-sm"><i class="fa fa-plus"></i>&nbsp; 发布比赛</a></li>
                    </ul>
                </div>
            </div>
        </div>

    </nav>

</div>

<div class="well">
    <div class="container  white-board white-board-block">

    </div>
</div>


<div class="footer">
    <div class="container">
        <div class="row">
            <div class="col-xs-12 col-sm-6">
                <div class="text-center">
                    <ul class="footer-block">
                        <li>
                            <dl>
                                <dt>AMK Project</dt>
                                <dd><a href="#">关于我们</a></dd>
                                <dd><a href="#">联系我们</a></dd>
                                <dd><a href="#">服务条款</a></dd>
                                <dd><a href="#">隐私政策</a></dd>
                            </dl>
                        </li>
                        <li>
                            <dl>
                                <dt>定制模块</dt>
                                <dd><a href="#">数理逻辑</a></dd>
                                <dd><a href="#">抽象代数</a></dd>
                                <dd><a href="#">离散数学</a></dd>
                            </dl>
                        </li>
                        <li>
                            <dl>
                                <dt>更多</dt>
                                <dd><a href="#">半自动证明</a></dd>
                                <dd><a href="#">证明检测</a></dd>
                            </dl>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="col-xs-12 col-sm-6">
                <div class="text-center">
                    <ul class="footer-block text-center">

                        <li>
                            <dl>
                                <dt><i class="fa fa-wechat"></i> 微信关注</dt>
                                <dd>
                                    <img src="img/qr_logo.jpg">
                                </dd>
                                <dd><small>AMK Project</small></dd>
                            </dl>
                        </li>
                        <li>
                            <dl>
                                <dt><i class="fa fa-weibo"></i> 新浪微博</dt>
                                <dd>
                                    <img src="img/weibo_logo.png">
                                </dd>
                                <dd><small>AMK</small></dd>
                            </dl>
                        </li>
                    </ul>
                </div>
            </div>

        </div>
        <div class="row">
            <div class="text-center">
                <span><small>版权所有 © amk.website </small></span>
            </div>

        </div>

    </div>

</div>

<script src="js/jquery.min.js"></script>
<script src="js/bootstrap.min.js"></script>
<script src="js/jquery.bxslider.min.js"></script>
<script>



</script>
</body>
</html>

<?php?>