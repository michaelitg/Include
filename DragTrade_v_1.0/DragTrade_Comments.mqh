/* =============================================================================================== */
/* Copyright (c) 2010 Andrey Nikolaevich Trukhanovich (aka TheXpert)                                  */
/*                                                                                                 */
/* Permission is hereby granted, free of charge, to any person obtaining a copy of this software           */
/* and associated documentation files (the "Software"),   */
/* to deal in the Software without restriction, including without limitation the rights           */
/* to use, copy, modify, merge, publish, distribute,                 */
/* sublicense, and/or sell copies of the Software, and to permit persons              */
/* to whom the Software is furnished to do so, subject to the following conditions:       */
/*                                                                                                 */
/*                                                                                                 */
/* The above copyright notice and this permission notice shall be included in all copies or substantial         */
/* portions of the Software.                                                         */
/*                                                                                                 */
/* THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS       */
/* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   */
/* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR     */
/* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       */
/* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR    */
/* IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER      */
/* DEALINGS IN THE SOFTWARE.                                                          */
/* =============================================================================================== */

//+------------------------------------------------------------------+
//|                                                     Comments.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, TheXpert"
#property link      "theforexpert@gmail.com"

int CommentsLines = 10;
int CommentsLineSize = 60;
int CommentsLinesTab = 8;

int CommentPointer;

string CommentsPrefixes[];
string Comments[];

string ReplaceTabs(string s)
{
   static string spaces = "                                          ";
   static string result;
   
   result = s;
   
   int pos = StringFind(result, "\t");
   while(pos >= 0)
   {
      int size = (pos - 1)/CommentsLinesTab*CommentsLinesTab + CommentsLinesTab - pos;
      
      if (size > 0)
      {
         result = 
            StringSubstr(result, 0, pos) +
            StringSubstr(spaces, 0, size) +
            StringSubstr(result, pos + 1);
      }
      else
      {
         result = 
            StringSubstr(result, 0, pos) +
            StringSubstr(result, pos + 1);
      }
         
      pos = StringFind(result, "\t");
   }
   return (result);
}

void Comment_Line(string comment, bool start)
{
   string s = comment;
   
   int size = StringLen(comment);
   bool isStart = start;
   
   if (size == 0)
   {
      Comment_Line_Impl(s, isStart);
      return;
   }
   
   while (size > 0)
   {
      Comment_Line_Impl(StringSubstr(s, 0, CommentsLineSize), isStart);
      s = StringSubstr(s, CommentsLineSize);
      
      size -= CommentsLineSize;
      isStart = false;
   }
}

void Comment_Line_Impl(string comment, bool start)
{
   string prefix = TimeToStr(TimeCurrent(), TIME_SECONDS);
   if (!start)
   {
      prefix = StringSubstr("                       ", 0, StringLen(prefix));
   }
   
   prefix = prefix + " |";
   
   if (CommentPointer < CommentsLines)
   {
      CommentsPrefixes[CommentPointer] = prefix;
      Comments[CommentPointer] = 
         StringSubstr(
            comment + 
            "                                                                ",
            0, CommentsLineSize) +
            " |";
      
      CommentPointer++;
   }
   else
   {
      for(int i = 1; i < CommentsLines; i++)
      {
         CommentsPrefixes[i - 1] = CommentsPrefixes[i];
         Comments[i - 1] = Comments[i];
      }
      CommentsPrefixes[CommentPointer - 1] = prefix;
      Comments[CommentPointer - 1] = 
         StringSubstr(
            comment + 
            "                                                                ",
            0, CommentsLineSize) +
            " |";
   }
}

void CommentsInit(int symbolsInLine, int lines, int tabSize)
{
   if (symbolsInLine < 20) symbolsInLine = 20;
   if (symbolsInLine > 60) symbolsInLine = 60;

   if (lines <= 0) lines = 1;
   
   if (tabSize < 3) tabSize = 3;
   if (tabSize > 20) tabSize = 20;
   
   SetCommentsLineSize(symbolsInLine);
   SetCommentsLines(lines);
   CommentsLinesTab = tabSize;
   CommentPointer = 0;
   
   ArrayResize(CommentsPrefixes, CommentsLines);
   ArrayResize(Comments, CommentsLines);
   
   for(int i = 0; i < CommentsLines; i++)
   {
      CommentsPrefixes[i] = "";
      Comments[i] = "";
   }
}

void Comment_(string comment)
{
   string s = ReplaceTabs(comment);
   int pos = StringFind(s, "\n");
   bool isStart = true;
   
   while(pos > 0)
   {
      Comment_Line(StringSubstr(s, 0, pos), isStart);
      s = StringSubstr(s, pos + 1);
      
      pos = StringFind(s, "\n");
      isStart = false;
   }

   Comment_Line(s, isStart);
}

void SetCommentsLineSize(int count)
{
   CommentsLineSize = count;
}

void SetCommentsLines(int count)
{
   if (count == CommentsLines) return;
   
   if (count < CommentsLines)
   {
      int differ = CommentsLines - count;
      int size = CommentsLines;
      for (int i = 0; i < count; i++)
      {
         Comments[i] = Comments[i + differ];
      }
   }
   ArrayResize(Comments, count);
   CommentsLines = count;
}