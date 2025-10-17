import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_entry.dart';

class FoodCard extends StatelessWidget {
  final FoodEntry entry;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  const FoodCard({super.key,required this.entry,this.onDelete,this.onTap});
  Color _bg(ReactionType r){switch(r){case ReactionType.like:return Colors.green.shade50;case ReactionType.neutral:return Colors.grey.shade100;case ReactionType.dislike:return Colors.orange.shade50;case ReactionType.allergy:return Colors.red.shade50;}}
  String _emoji(ReactionType r){switch(r){case ReactionType.like:return '❤️';case ReactionType.neutral:return '😐';case ReactionType.dislike:return '👎';case ReactionType.allergy:return '⚠️';}}
  @override Widget build(BuildContext context){
    final df=DateFormat('d MMM yyyy');
    return Card(color:_bg(entry.reaction),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),margin:EdgeInsets.symmetric(vertical:8),child:ListTile(onTap:onTap,contentPadding:EdgeInsets.symmetric(horizontal:16,vertical:12),leading:CircleAvatar(child:Text(entry.name[0].toUpperCase())),title:Text(entry.name,style:TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(df.format(entry.dateTried)),trailing:Row(mainAxisSize:MainAxisSize.min,children:[Text(_emoji(entry.reaction),style:TextStyle(fontSize:20)),IconButton(icon:Icon(Icons.delete_outline),onPressed:onDelete)])));
  }
}
