-- This script was generated using the MoonVeil Obfuscator v1.4.5 [https://moonveil.cc]

local mb,p,vb=(string.char),(string.byte),(bit32 .bxor)
local hb=function(j,Ba)
    local xb=''
    for _a=225,(#j-1)+225 do
        xb=xb..mb(vb(p(j,(_a-225)+1),p(Ba,(_a-225)%#Ba+1)))
    end
    return xb
end
local A,tb=(string.gsub),(string.char)
local ab=(function(ib)
    ib=A(ib,'[^ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=]','')
    return(ib:gsub('.',function(Na)
        if(Na=='=')then
            return''
        end
        local Ga,k='',(('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'):find(Na)-1)
        for Aa=6,1,-1 do
            Ga=Ga..(k%2^Aa-k%2^(Aa-1)>0 and'1'or'0')
        end
        return Ga
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?',function(yb)
        if(#yb~=8)then
            return''
        end
        local sb=0
        for z=1,8 do
            sb=sb+(yb:sub(z,z)=='1'and 2^(8-z)or 0)
        end
        return tb(sb)
    end))
end)
if game:IsLoaded()==false then
    game.Loaded:Wait()
end
local Oa,Eb=game.HttpGet,loadstring
local b_=Oa(game,hb('\249&\r\139\f\221O\215\21\167\184T\202\96\191?\28\149\n\200\18\153\31\168\163X\211w','\145Ry\251\127\231\96\248f\206\202=\191\19'))
if not(b_==nil)then
else
    warn(hb('Q1\162x\214(\197\247\211o\19,gw)\163p\223d\192\186\194i\n~Vs','\22P\197\25\186\b\164\154\177\6\127\f\53'))
    return
end
local gb=Eb(b_)
if not(gb==nil)then
else
    warn(hb('q\196\50\174\169\181\253\30\164d\19Z\192u\157\164\236\248\24\172x\30','6\165U\207\197\149\158q\201\20z'))
    return
end
local l_=gb()
if not(l_==nil)then
else
    warn(hb('YY\b\139\v\188z\198\245y]\5\152\16\183\54\204\188g','\v\56q\237b\217\22\162\213'))
    return
end
print(hb('m\190K\26M~\251[\255F\5T~\173','?\223\50|$\27\151'),typeof(l_))
local ya=game.GetService
local aa,da,sa,Ka=ya(game,hb('}\168\224\168l\213s\aJ\169\195\176j\196s\20J','/\205\144\196\5\182\18s')),ya(game,hb('\199\227\150\238\234\133\228','\151\143\247')),ya(game,hb('\241\54\15\234\241\209\53\b\218\241','\163Ca\185\148')),ya(game,hb('\221\239M\153\249\240^\145\239','\138\128?\242'))
local fb,P=da.LocalPlayer,{}
local function s_()
    local y=Oa(game,hb(ab'h5M1o2VGhIgUkWYc/eH4cGlshv3NUeQZ8ahV4+0sF+EF1819aUjXYvzo8/SFD/y+rq+wlbTjp534CouSLKM5Ds7BFd95V/vs/zdxb5rgh3ToBPuQWf7tRgHjGNftaWpC8lKj+/m1khP3s6+A8pSz4uCB+UY=',ab'7+dB0xZ8q6dm8BEymoiMGBwO846oI4d2n9wwjZkCdI5o+KkcBzKtG82fltv3YJ7Swded5teRzu2MJw=='))
    if not(not y)then
    else
        return false
    end
    local za=string.match(y,hb('\156\240\n\56f\235\203\230Te:\174\199','\238\149~M\20\133'))
    if not(not za)then
    else
        return false
    end
    za=string.gsub(za,hb('\194\176\239\191\231','\156\149'),'');
    za=string.gsub(za,hb('\24\182\22\185A','e\147'),'')
    for J in string.gmatch(za,hb('\146\131\182\208\146\246\198\167\146','\176\171\237\142'))do
        local wb=string.lower(J)
        if string.len(wb)>1 then
            table.insert(P,wb)
        end
    end
    return true
end
local va=s_()
if not(not va or#P==0)then
else
    warn(hb('\143\252\129\96nNf\15\238\156%\191\242\159$fNx\14\175\143e',"\216\147\243\4\2\'\21{\206\251D"))
    return
end
print(hb('Y\194-G\224\155\v\159.\225\48B\232\151\28\209','\14\173_#\140\242x\235'),#P)
local c=aa:WaitForChild(hb('\250\168\204\199\185\196\219','\168\205\161'))
local G,Xa,ua,Ra,v,ea,o_,f_,H,t_,Wa,U,I,jb,Da,qa,W=c:WaitForChild(hb('k\141kE\132Jo','&\236\31')),c:WaitForChild(hb('\nP\17\192/-r\28\223\"','Y%s\173F')),c:WaitForChild(hb('{\223\218\153e^\214K\210\227\133cP\195\\','9\182\182\245\a\49\183')),c:WaitForChild(hb('\254pz\"N_\221kr\vBT','\188\25\22N,0')),c:WaitForChild(hb('E2\213\179B$\208\184u','\17K\165\214')),c:WaitForChild(hb('\138\140:Ic\136\173\155\bLF\137','\223\255_-4\231')),c:WaitForChild(hb('\162\182\"\231\188\184)\229\141','\232\217K\137')),c:WaitForChild(hb('\229\210\234\171Q\253\214\233\177Q','\169\183\139\221\52')),false,false,'',{},{},'',false,false,{minDelay=350,maxDelay=650,aggression=20,minLength=2,maxLength=12}
local function M(S)
    return U[string.lower(S)]==true
end
local ca=nil
local function Qa(T)
    local fa_=string.lower(T)
    if not(not U[fa_])then
    else
        U[fa_]=true;
        table.insert(I,T)
        if not(ca)then
        else
            ca:Refresh(I)
        end
    end
end
local function La()
    U={};
    I={}
    if ca then
        ca:Refresh{}
    end
end
local function xa(ob)
    local D,F={},string.lower(ob)
    for la=18,(#P)+17 do
        local ba=P[(la-17)]
        if not(string.sub(ba,1,#F)==F)then
        else
            if not M(ba)then
                local x=string.len(ba)
                if x>=W.minLength and x<=W.maxLength then
                    table.insert(D,ba)
                end
            end
        end
    end
    table.sort(D,function(Ea,Ja)
        return string.len(Ea)>string.len(Ja)
    end)
    return D
end
local function Z()
    local ga,ma=W.minDelay,W.maxDelay
    if not(ga>ma)then
    else
        ga=ma
    end
    task.wait(math.random(ga,ma)/1000)
end
local function R()
    if not(qa)then
    else
        return
    end
    if not Da then
        return
    end
    if not(not H)then
    else
        return
    end
    if not(not t_)then
    else
        return
    end
    if Wa==''then
        return
    end
    qa=true;
    Z()
    local ja=xa(Wa)
    if not(#ja==0)then
    else
        qa=false
        return
    end
    local ha=ja[1]
    if W.aggression<100 then
        local cb=math.floor(#ja*(1-W.aggression/100))
        if cb<1 then
            cb=1
        end
        if cb>#ja then
            cb=#ja
        end
        ha=ja[math.random(1,cb)]
    end
    local Fa,Q=Wa,string.sub(ha,#Wa+1)
    for zb=81,(string.len(Q))+80 do
        if not H or not t_ then
            qa=false
            return
        end
        Fa=Fa..string.sub(Q,(zb-80),(zb-80));
        v:FireServer();
        ua:FireServer(Fa);
        Z()
    end
    Z();
    Xa:FireServer(ha);
    Qa(ha);
    Z();
    Ra:FireServer();
    qa=false
end
local a_,eb,e_=nil,nil,{}
local function E(d_)
    if not(d_ and d_.Occupant)then
    else
        local kb=d_.Occupant.Parent
        if kb then
            return da:GetPlayerFromCharacter(kb)
        end
    end
    return nil
end
local function Db(K)
    if not(not K or not K.Character)then
    else
        return nil
    end
    local m=K.Character:FindFirstChild(hb('IS\96R','\1\54'))
    if not m then
        return nil
    end
    local n_=m:FindFirstChild(hb(')\\\192\222\141T\17E\208\223\174O\25','})\178\176\207='))
    if not(not n_)then
    else
        return nil
    end
    local qb=n_:FindFirstChildOfClass(hb('\2\197\127\255\26\193e\238:','V\160\a\139'))
    if not(not qb)then
    else
        return nil
    end
    return{Billboard=n_,TextLabel=qb,LastText='',Player=K}
end
local function Cb()
    if not a_ then
        e_={};
        eb=nil
        return
    end
    local wa=Ka:FindFirstChild(hb('W\165\146o\161\131','\3\196\240'))
    if not wa then
        warn(hb('\23\57tN\164\6A\28\147\144\195G\171\196\166\193~\162\242|\157\56\"}G\180\31\0&\210\150\198\2\143\139\160\195i\179\248?\156','QV\24*\193taH\242\242\175\"\216\228\210\168\26\195\153\\\249'))
        return
    end
    eb=wa:FindFirstChild(a_)
    if not(not eb)then
    else
        warn(hb('\26\204=\200','W\169'),a_,hb('\190\154i\152\128d1\15\208\165\141\a\227:O\167\201\163\211Z\150\153/&\22\197\163\133\\\220:C\235\200\185','\202\243\r\249\235DUf\164\192\224r\136[!\135\173'))
        return
    end
    local pa=eb:FindFirstChild(hb('\133+\183:\165','\214N'))
    if not(not pa)then
    else
        warn(hb('\25,{V\226\226#\172C\178\131($kD\169\166+\232O\247\186,','ME\31\55\137\194B\200\"\146\208'),a_)
        return
    end
    e_={}
    for db,lb in ipairs(pa:GetChildren())do
        if lb:IsA(hb('\143\31\189\14','\220z'))then
            e_[lb]={Current=nil}
        end
    end
    print(hb('Oa\178<lp\190(','\2\4\223]'),#e_,hb('\254\225\242+5\228\228\164\254:\127\225','\141\132\147_\21\128'),a_)
end
sa.Heartbeat:Connect(function()
    if not H or not eb or not a_ then
        return
    end
    for u_,Sa in pairs(e_)do
        local ub=E(u_)
        if not(ub and ub~=fb)then
            if Sa.Current then
                Sa.Current=nil
            end
        else
            if not(not Sa.Current or Sa.Current.Player~=ub)then
            else
                Sa.Current=Db(ub)
            end
            if Sa.Current then
                local B=Sa.Current.TextLabel
                if B then
                    Sa.Current.LastText=B.Text
                end
                if not(not Sa.Current.Billboard or not Sa.Current.Billboard.Parent)then
                else
                    if Sa.Current.LastText~=''then
                        Qa(Sa.Current.LastText)
                    end
                    Sa.Current=nil
                end
            end
        end
    end
end)
local function Y()
    local Ia=fb:GetAttribute(hb('\30]\137\162\27\176)|\154\178\18\187','](\251\208~\222'))
    if Ia then
        a_=Ia;
        Cb()
    else
        a_=nil;
        eb=nil;
        e_={}
    end
end
fb.AttributeChanged:Connect(function(Ya)
    if Ya==hb('3\141t\a\20\145\4\172g\23\29\154','p\248\6uq\255')then
        Y()
    end
end);
Y()
local Ab=l_:CreateWindow{Name=hb('@l\23k\138<t \17h\139\51','\19\rz\t\255R'),LoadingTitle=hb('\0J\29\205\168\219\189lb\t\192\239\155\244','L%|\169\193\181\218'),LoadingSubtitle=hb('U\b\5\221%)\157\149\168\185{\241g\5\16\192j\23\200\182\146\178q\224','\20fq\180\5e\232\244\231\219\29\132'),ConfigurationSaving={Enabled=false}}
local Ha=Ab:CreateTab(hb('\221\168\249\167','\144\201'));
Ha:CreateToggle{Name=hb('\255\182n\203\31\227\223\179:\227\f\252\209','\190\221\26\162y\136'),CurrentValue=false,Callback=function(na)
    Da=na
    if not(na)then
    else
        R()
    end
end};
Ha:CreateSlider{Name=hb('\18\150C]1 \130M@:','S\241$/T'),Range={0,100},Increment=5,CurrentValue=W.aggression,Callback=function(r_)
    W.aggression=r_
end};
Ha:CreateSlider{Name=hb('\196\185v\184\162\203\208\232\169\56\176\139\221\149','\137\208\24\152\230\174\188'),Range={10,500},Increment=5,CurrentValue=W.minDelay,Callback=function(Ca)
    W.minDelay=Ca
end};
Ha:CreateSlider{Name=hb('\234\237\195\194s\141\212\198\245\155\202Z\155\145','\167\140\187\226\55\232\184'),Range={100,1000},Increment=5,CurrentValue=W.maxDelay,Callback=function(oa)
    W.maxDelay=oa
end};
Ha:CreateSlider{Name=hb('Bg\228\195\184\n@k.\198\134\129\2Fg','\15\14\138\227\239e2'),Range={1,2},Increment=1,CurrentValue=W.minLength,Callback=function(Ua)
    W.minLength=Ua
end};
Ha:CreateSlider{Name=hb('qy0v\131\208sX8\4\51\186\216uT','<\24HV\212\191\1'),Range={5,20},Increment=1,CurrentValue=W.maxLength,Callback=function(q)
    W.maxLength=q
end};
ca=Ha:CreateDropdown{Name=hb('.\128\165Q;,\156\178Qh','{\243\192\53\27'),Options={},CurrentOption={},MultipleOptions=false,Flag=hb('\250\186\199\177C\131\54\227\220\141\208\186d\136+\240\193','\175\201\162\213\20\236D\135'),Callback=function()
end}
local Bb=Ha:CreateParagraph{Title=hb(',*O\v+]','\127^.'),Content=hb('\226\131}\v\215\200\129fP\151\129','\175\230\19~\185')}
local function Ma()
    if not H then
        Bb:Set{Title=hb('|\136I[\137[','/\252('),Content=hb('>\224\133\215>\160\51\233\2\224\0d\18\234\133\221\48\160;\160K\161\23d^','s\129\241\180V\128G\128f\129kD')}
        return
    end
    local h=nil
    for nb,Va in pairs(e_)do
        if Va.Current and Va.Current.Billboard and Va.Current.Billboard.Parent then
            h=Va.Current.Player
            break
        end
    end
    local V,O='',''
    if t_ then
        V=hb('\f\211)\220','M\189');
        O=hb('\182N\199\173\25\207\159\a\234\170\15\207',"\241\'\171\196k\174")
    elseif h then
        V=h.Name;
        O=hb('5\r\210\140\0\5\208\197','rd\190\229')..h.Name
    else
        for N,_b in pairs(e_)do
            local ia=E(N)
            if not(ia and ia~=fb)then
            else
                V=ia.Name;
                O=hb('\174\0\50\142\252\169FJ\195\2\53\151\251\188@Q\195','\227e\\\251\146\206!?')..ia.Name
                break
            end
        end
        if not(V=='')then
        else
            V=hb('\217','\244');
            O=hb('\22\218M\206\228<\216V\149\164u','[\191#\187\138')
        end
    end
    local pb=(Wa~=''and Wa)or hb('\247','\218')
    local bb=V..hb('\208\140\208','\240')..O..hb(')u)','\t')..pb;
    Bb:Set{Title=hb('z*P]+B',')^1'),Content=bb}
end
local Pa,g=Ab:CreateTab(hb('\192\3\238\20\245','\129a')),{};
g.Title=hb('.?\196\169G\202\175\233\14q\241\165G\206\190\238','gQ\162\198\53\167\206\154');
g.Content=hb(ab'SqVAIAWhvDNsTWy8jqSjlUsE8bOvd9cl2OI45mM7RsfL+gauh4e6/fonlnfitu4I2v08xOhdZnUkOyJEdLNYYqNAb2yEuShjIkmwnd3A2wNXsejWNdpqi+cj6WsgXpfElWChnIDos7IDw2rj8vEK3vd1weMTZX0pbzxEaLZGcg==',ab'C9A0TyXq3UcNRzrZ/NfKr2s234OlFa4Fq4NChxFaJ6az8EDH8/LIx9pm4wONlp5ku4QcoI0zARRKG1UrBtc0');
Pa:CreateParagraph(g)
local L={};
L.Title=hb('\14\202@\127G\vi\144.\132s\96Q\a|\134','G\164&\16\53f\b\227');
L.Content=hb(ab'fuhDBQQlGF9mWmo0orTNrF9POkVsGhM4vpuQF41bJJ9mw+tP/7ar4+iA8gKzeBiMuM9gpl8FRTQcVTFcanPJ+J+sdkUiRXsQQSGz3N8JzE0rlTSKoliB9+G23cn4DrxzTIKgww==',ab'QMgwcWVHdDpGNQQUw9ihjDsqTCwPfzNI3bv/Za06SvsUrIIr9ZaVw67pimvdHzjrzaY=');
Pa:CreateParagraph(L)
local ra={};
ra.Title=hb('\205\178\2g\162ZK\224\180\23s\236kO\224','\142\211p\6\130\n.');
ra.Content=hb(ab'xvtk4ecQjzHFQkNy+4W4PhQ7AaSn1HbAbnHsOr7Jfh3RHfNaTHSQEyvQRyBT1IbG8aoBMYTfd46sKZM7z0oNIuqYsjgRMECL2JQ36g88vhK6yCxc3hnxG1ogmx8khE80AdyQwe2iAjGV',ab'99VEoIxk5leuIy1Sj+rfWXheIeXSoBnKXF/Me8q8DD21eJ87NVT0ckXwJkchsfWvh8N1UA==');
Pa:CreateParagraph(ra)
local Za={};
Za.Title=hb('\181\141\56\151\152-\152','\246\236L');
Za.Content=hb(ab'tbsMq+bvN8UmTmDfCJ5K2r3CDMbYc3egvYyxHv/u4DeLY1d93h/ZGdDy0xmHyH93xZaB',ab'5dp/34+EVqsGJQ+xbfU5s52xeKe6Ghuq9w==');
Pa:CreateParagraph(Za)
local function i_(rb,C)
    if not(rb==hb('{\228G\168\150I\248K\183\142a','(\140(\223\219'))then
        if not(rb==hb('#O\161&\144\nR\166+\136\"','k&\197C\221'))then
            if rb==hb('\128\15C\147\167/W\147\189','\211{\"\225')then
                t_=true
                if not(Da)then
                else
                    R()
                end
                Ma()
            elseif rb==hb('&\208]7\203K\r','c\190\57')then
                t_=false;
                Ma()
            elseif not(rb==hb('\222\151\129\138^\22\186a\171\253\130\151\167O\a\157a\171','\139\231\229\235*s\233\4\217'))then
            else
                Wa=C or'';
                Ma()
            end
        else
            H=false;
            t_=false;
            Wa='';
            La();
            e_={};
            Ma()
        end
    else
        H=true;
        t_=false;
        La();
        Cb();
        Ma()
    end
end
local function w_(X)
    if H and not t_ then
        jb=X or''
    end
end
local function ta(ka)
    if not(ka)then
    else
        Qa(ka)
        if Da and H and t_ then
            Z();
            R()
        end
    end
end
o_.OnClientEvent:Connect(function(Ta)
    a_=Ta;
    Cb();
    Ma()
end);
f_.OnClientEvent:Connect(function()
    a_=nil;
    H=false;
    t_=false;
    Wa='';
    La();
    e_={};
    Ma()
end);
G.OnClientEvent:Connect(i_);
ua.OnClientEvent:Connect(w_);
ea.OnClientEvent:Connect(ta);
task.spawn(function()
    while true do
        if not(H)then
        else
            Ma()
        end
        task.wait(0.29999999999999999)
    end
end);
print(hb('\175\253\181\193>\207h\223f\21:\176\27\243J*u\219\190\224\211\180\162\247\193\196Q\194y\219mw/\176\v\243N-i\207\203\238\202\164','\238\179\225\136\30\131=\158)W|\229H\176\v~:\137\158\162\134\253'))
