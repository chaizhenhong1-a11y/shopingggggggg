import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/seller_application_repository.dart';

class SellerApplicationPage extends ConsumerStatefulWidget {
  const SellerApplicationPage({super.key});
  @override ConsumerState<SellerApplicationPage> createState()=>_SellerApplicationPageState();
}

class _SellerApplicationPageState extends ConsumerState<SellerApplicationPage> {
  final formKey=GlobalKey<FormState>();
  final store=TextEditingController(),contact=TextEditingController(),phone=TextEditingController(),address=TextEditingController(),type=TextEditingController(),description=TextEditingController();
  Map<String,dynamic>? application; bool loading=true,submitting=false; String? error;
  SellerApplicationRepository get repo=>SellerApplicationRepository(ref.read(apiClientProvider));
  @override void initState(){super.initState();Future.microtask(load);}
  Future<void> load()async{try{final value=await repo.mine();if(mounted)setState((){application=value;loading=false;error=null;});}catch(e){if(mounted)setState((){loading=false;error=e.toString();});}}
  Future<void> submit()async{if(!formKey.currentState!.validate())return;setState(()=>submitting=true);try{await repo.submit({'storeName':store.text,'contactName':contact.text,'phone':phone.text,'address':address.text,'businessType':type.text,'description':description.text});await load();}catch(e){if(mounted)setState(()=>error=e.toString());}finally{if(mounted)setState(()=>submitting=false);}}
  @override Widget build(BuildContext context){final user=ref.watch(authProvider).asData?.value;if(user==null)return const Scaffold(body:Center(child:Text('请先登录')));return Scaffold(appBar:AppBar(title:const Text('申请成为卖家',style:TextStyle(fontWeight:FontWeight.w900))),body:loading?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.all(18),children:[if(error!=null)Container(padding:const EdgeInsets.all(12),margin:const EdgeInsets.only(bottom:12),decoration:BoxDecoration(color:const Color(0xFFFFE9E4),borderRadius:BorderRadius.circular(12)),child:Text(error!,style:const TextStyle(color:Colors.red))),if(application!=null)_StatusCard(application:application!,onRetry:application!['status']=='REJECTED'?()=>setState(()=>application=null):null)else Form(key:formKey,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const Text('店铺资料',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900)),const SizedBox(height:6),const Text('资料提交后由平台管理员审核，通过后使用原账号登录商家后台。',style:TextStyle(color:AppColors.muted)),const SizedBox(height:20),_field(store,'店铺名称'),_field(contact,'联系人姓名'),_field(phone,'联系电话',keyboard:TextInputType.phone),_field(address,'经营地址'),_field(type,'经营类型',hint:'例如：服装、美妆、家居'),_field(description,'店铺介绍（选填）',required:false,lines:4),const SizedBox(height:8),FilledButton(onPressed:submitting?null:submit,style:FilledButton.styleFrom(backgroundColor:AppColors.primary,padding:const EdgeInsets.all(15)),child:Text(submitting?'提交中…':'提交入驻申请'))]))]));}
  Widget _field(TextEditingController c,String label,{String? hint,bool required=true,int lines=1,TextInputType? keyboard})=>Padding(padding:const EdgeInsets.only(bottom:14),child:TextFormField(controller:c,maxLines:lines,keyboardType:keyboard,decoration:InputDecoration(labelText:label,hintText:hint,filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14))),validator:(v)=>required&&(v==null||v.trim().isEmpty)?'请填写$label':null));
}

class _StatusCard extends StatelessWidget{final Map<String,dynamic> application;final VoidCallback? onRetry;const _StatusCard({required this.application,this.onRetry});@override Widget build(BuildContext context){final status=application['status'];final approved=status=='APPROVED',rejected=status=='REJECTED';return Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),child:Column(children:[Icon(approved?Icons.verified:rejected?Icons.cancel:Icons.schedule,size:62,color:approved?Colors.green:rejected?Colors.red:Colors.orange),const SizedBox(height:12),Text(approved?'申请已通过':rejected?'申请未通过':'申请审核中',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:8),Text(application['storeName']??'',style:const TextStyle(fontWeight:FontWeight.w700)),if(rejected)...[const SizedBox(height:12),Text('原因：${application['rejectionReason']??'未填写'}'),const SizedBox(height:18),FilledButton(onPressed:onRetry,child:const Text('修改资料后重新申请'))],if(approved)...[const SizedBox(height:12),const Text('请重新登录账号，使新的卖家权限生效。')]]) );}}
